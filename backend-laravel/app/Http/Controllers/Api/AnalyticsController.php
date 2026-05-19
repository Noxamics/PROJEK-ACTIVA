<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AnalyticsLog;
use App\Models\MlResult;
use App\Models\Questionnaire; // pastikan model ini ada
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

/**
 * AnalyticsController
 * ─────────────────────────────────────────────────────
 * Endpoint insight & analitik untuk:
 *  - Dashboard Flutter (insight page)
 *  - Dashboard Web (grafik)
 *  - Admin panel
 */
class AnalyticsController extends Controller
{
    /**
     * GET /api/analytics/insight
     * Insight personal user: perubahan dependensi 7 hari
     */
    public function insight(): JsonResponse
    {
        $userId = auth()->id();

        $last7 = MlResult::where('user_id', $userId)
            ->where('created_at', '>=', now()->subDays(7))
            ->orderBy('created_at', 'asc')
            ->get();

        $prev7 = MlResult::where('user_id', $userId)
            ->whereBetween('created_at', [now()->subDays(14), now()->subDays(7)])
            ->get();

        $avgDepCurrent = $last7->avg(fn($r) => $r->ml_result['digital_dependence_score'] ?? 0) ?? 0;
        $avgDepPrev = $prev7->avg(fn($r) => $r->ml_result['digital_dependence_score'] ?? 0) ?? 0;

        $depChange = $avgDepPrev > 0
            ? round((($avgDepCurrent - $avgDepPrev) / $avgDepPrev) * 100, 1)
            : 0;

        AnalyticsLog::create([
            'user_id' => $userId,
            'avg_dependence_7_days' => round($avgDepCurrent, 2),
            'dependence_change_percentage' => $depChange,
            'created_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'period' => '7 hari terakhir',
                'avg_dependence_score' => round($avgDepCurrent, 2),
                'dependence_change_percentage' => $depChange,
                'dependence_change_label' => $this->changeLabel($depChange),
                'high_risk_days' => $last7->filter(
                    fn($r) =>
                    ($r->ml_result['category'] ?? '') === 'tinggi'
                )->count(),
                'total_surveys_week' => $last7->count(),
                'daily_trend' => $last7->map(fn($r) => [
                    'date' => Carbon::parse($r->created_at)->format('Y-m-d'),
                    'dependence_score' => $r->ml_result['digital_dependence_score'] ?? 0,
                    'category' => $r->ml_result['category'] ?? 'rendah',
                    'confidence' => $r->ml_result['confidence'] ?? 0,
                ]),
            ],
        ]);
    }

    /**
     * GET /api/analytics/comparison
     * Perbandingan user dengan rata-rata semua user (anonymized)
     */
    public function comparison(): JsonResponse
    {
        $userId = auth()->id();

        $myLatest = MlResult::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->first();

        $global = MlResult::where('created_at', '>=', now()->subDays(30))->get();

        return response()->json([
            'success' => true,
            'data' => [
                'my_scores' => $myLatest ? [
                    'dependence_score' => $myLatest->ml_result['digital_dependence_score'] ?? 0,
                    'category' => $myLatest->ml_result['category'] ?? 'rendah',
                    'confidence' => $myLatest->ml_result['confidence'] ?? 0,
                ] : null,
                'global_avg' => [
                    'dependence_score' => round(
                        $global->avg(fn($r) => $r->ml_result['digital_dependence_score'] ?? 0),
                        2
                    ),
                    'sample_size' => $global->count(),
                ],
            ],
        ]);
    }

    /**
     * GET /api/analytics/history?days=30
     * History lengkap user untuk grafik di web/Flutter (endpoint lama, tetap dipertahankan)
     */
    public function history(Request $request): JsonResponse
    {
        $days = min((int) $request->get('days', 30), 90);

        $results = MlResult::where('user_id', auth()->id())
            ->where('created_at', '>=', now()->subDays($days))
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'days' => $days,
                'records' => $results->map(fn($r) => [
                    'date' => Carbon::parse($r->created_at)->format('Y-m-d'),
                    'dependence_score' => $r->ml_result['digital_dependence_score'] ?? 0,
                    'category' => $r->ml_result['category'] ?? 'rendah',
                    'confidence' => $r->ml_result['confidence'] ?? 0,
                    'week_group' => $r->week_group,
                ]),
            ],
        ]);
    }

    /**
     * GET /api/analytics/grafik?period=week|monthly|yearly
     *
     * Endpoint baru khusus untuk GrafikScreen Flutter.
     * Menggabungkan data dari ml_results dan questionnaires.
     *
     * Period:
     *   week    → 7 hari terakhir, 1 titik per hari
     *   monthly → 4 minggu terakhir, 1 titik per minggu (rata-rata)
     *   yearly  → 12 bulan terakhir, 1 titik per bulan (rata-rata)
     */
    public function grafik(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $period = $request->get('period', 'week');

        return match ($period) {
            'monthly' => $this->grafikMonthly($userId),
            'yearly'  => $this->grafikYearly($userId),
            default   => $this->grafikWeek($userId),
        };
    }

    // ─── Private: grafik per periode ─────────────────────────────────────────

    /**
     * 7 hari terakhir → 7 titik, label: Sen/Sel/.../Min
     */
    private function grafikWeek(string $userId): JsonResponse
    {
        $days = collect();
        for ($i = 6; $i >= 0; $i--) {
            $days->push(now()->subDays($i)->startOfDay());
        }

        $entries = $days->map(function (Carbon $day) use ($userId) {
            // Ambil ml_result hari ini
            $ml = MlResult::where('user_id', $userId)
                ->whereDate('created_at', $day->toDateString())
                ->orderBy('created_at', 'desc')
                ->first();

            // Ambil questionnaire hari ini (via questionnaire_id di ml_result,
            // atau langsung cari berdasarkan user_id + tanggal)
            $survey = null;
            if ($ml && $ml->questionnaire_id) {
                $survey = Questionnaire::find($ml->questionnaire_id);
            } else {
                $survey = Questionnaire::where('user_id', $userId)
                    ->whereDate('created_at', $day->toDateString())
                    ->orderBy('created_at', 'desc')
                    ->first();
            }

            $dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
            $label    = $dayNames[$day->dayOfWeek];

            return [
                'label'             => $label,
                'date'              => $day->toDateString(),
                'dependence_score'  => $ml ? ($ml->ml_result['digital_dependence_score'] ?? null) : null,
                'category'          => $ml ? ($ml->ml_result['category'] ?? null) : null,
                'device_hours'      => $survey?->device_hours_per_day,
                'social_media_mins' => $survey?->social_media_minutes,
                'sleep_hours'       => $survey?->sleep_hours,
                'has_data'          => $ml !== null || $survey !== null,
            ];
        });

        return $this->grafikResponse('week', $entries->values()->all());
    }

    /**
     * 4 minggu terakhir → 4 titik, label: M1/M2/M3/M4
     * Setiap titik = rata-rata nilai dalam minggu tersebut
     */
    private function grafikMonthly(string $userId): JsonResponse
    {
        $entries = collect();

        for ($w = 3; $w >= 0; $w--) {
            $weekStart = now()->startOfWeek()->subWeeks($w);
            $weekEnd   = (clone $weekStart)->endOfWeek();
            $weekNum   = 4 - $w; // M1, M2, M3, M4

            $mls = MlResult::where('user_id', $userId)
                ->whereBetween('created_at', [$weekStart, $weekEnd])
                ->get();

            $surveys = Questionnaire::where('user_id', $userId)
                ->whereBetween('created_at', [$weekStart, $weekEnd])
                ->get();

            $entries->push([
                'label'             => "M{$weekNum}",
                'date'              => $weekStart->toDateString(),
                'dependence_score'  => $mls->isNotEmpty()
                    ? round($mls->avg(fn($r) => $r->ml_result['digital_dependence_score'] ?? 0), 1)
                    : null,
                'category'          => $this->dominantCategory($mls),
                'device_hours'      => $surveys->isNotEmpty()
                    ? round($surveys->avg('device_hours_per_day'), 1)
                    : null,
                'social_media_mins' => $surveys->isNotEmpty()
                    ? round($surveys->avg('social_media_minutes'), 0)
                    : null,
                'sleep_hours'       => $surveys->isNotEmpty()
                    ? round($surveys->avg('sleep_hours'), 1)
                    : null,
                'has_data'          => $mls->isNotEmpty() || $surveys->isNotEmpty(),
            ]);
        }

        return $this->grafikResponse('monthly', $entries->values()->all());
    }

    /**
     * 12 bulan terakhir → 12 titik, label: Jan/Feb/.../Des
     * Setiap titik = rata-rata nilai dalam bulan tersebut
     */
    private function grafikYearly(string $userId): JsonResponse
    {
        $monthNames = [
            1  => 'Jan', 2  => 'Feb', 3  => 'Mar', 4  => 'Apr',
            5  => 'Mei', 6  => 'Jun', 7  => 'Jul', 8  => 'Agt',
            9  => 'Sep', 10 => 'Okt', 11 => 'Nov', 12 => 'Des',
        ];

        $entries = collect();

        for ($m = 11; $m >= 0; $m--) {
            $monthStart = now()->startOfMonth()->subMonths($m);
            $monthEnd   = (clone $monthStart)->endOfMonth();

            $mls = MlResult::where('user_id', $userId)
                ->whereBetween('created_at', [$monthStart, $monthEnd])
                ->get();

            $surveys = Questionnaire::where('user_id', $userId)
                ->whereBetween('created_at', [$monthStart, $monthEnd])
                ->get();

            $entries->push([
                'label'             => $monthNames[$monthStart->month],
                'date'              => $monthStart->toDateString(),
                'dependence_score'  => $mls->isNotEmpty()
                    ? round($mls->avg(fn($r) => $r->ml_result['digital_dependence_score'] ?? 0), 1)
                    : null,
                'category'          => $this->dominantCategory($mls),
                'device_hours'      => $surveys->isNotEmpty()
                    ? round($surveys->avg('device_hours_per_day'), 1)
                    : null,
                'social_media_mins' => $surveys->isNotEmpty()
                    ? round($surveys->avg('social_media_minutes'), 0)
                    : null,
                'sleep_hours'       => $surveys->isNotEmpty()
                    ? round($surveys->avg('sleep_hours'), 1)
                    : null,
                'has_data'          => $mls->isNotEmpty() || $surveys->isNotEmpty(),
            ]);
        }

        return $this->grafikResponse('yearly', $entries->values()->all());
    }

    // ─── Private Helpers ─────────────────────────────────────────────────────

    /**
     * Format response grafik standar.
     * Kategori (low/medium/high) dihitung dari semua entry yang punya data.
     */
    private function grafikResponse(string $period, array $entries): JsonResponse
    {
        $withData = array_filter($entries, fn($e) => $e['has_data']);

        $low    = count(array_filter($withData, fn($e) => ($e['category'] ?? '') === 'rendah'));
        $medium = count(array_filter($withData, fn($e) => ($e['category'] ?? '') === 'sedang'));
        $high   = count(array_filter($withData, fn($e) => ($e['category'] ?? '') === 'tinggi'));

        return response()->json([
            'success' => true,
            'data'    => [
                'period'  => $period,
                'entries' => $entries,
                'kategori' => [
                    'low'    => $low,
                    'medium' => $medium,
                    'high'   => $high,
                ],
            ],
        ]);
    }

    /**
     * Tentukan kategori dominan dari kumpulan MlResult.
     * Digunakan untuk label kategori pada periode weekly/monthly.
     */
    private function dominantCategory($mls): ?string
    {
        if ($mls->isEmpty()) return null;

        $counts = ['rendah' => 0, 'sedang' => 0, 'tinggi' => 0];
        foreach ($mls as $r) {
            $cat = $r->ml_result['category'] ?? 'rendah';
            if (isset($counts[$cat])) $counts[$cat]++;
        }
        arsort($counts);
        return array_key_first($counts);
    }

    private function changeLabel(float $pct): string
    {
        // Untuk dependensi, naik = buruk, turun = baik (kebalikan dari focus)
        if ($pct > 10)  return 'Meningkat signifikan (perlu perhatian)';
        if ($pct > 0)   return 'Sedikit meningkat';
        if ($pct == 0)  return 'Tidak berubah';
        if ($pct > -10) return 'Sedikit menurun (membaik)';
        return 'Menurun signifikan (membaik)';
    }
}