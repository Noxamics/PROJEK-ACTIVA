<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AnalyticsLog;
use App\Models\MlResult;
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

        // Ambil hasil ML 7 hari terakhir
        $last7 = MlResult::where('user_id', $userId)
            ->where('created_at', '>=', now()->subDays(7))
            ->orderBy('created_at', 'asc')
            ->get();

        // Ambil hasil ML 7 hari sebelumnya (untuk perbandingan)
        $prev7 = MlResult::where('user_id', $userId)
            ->whereBetween('created_at', [now()->subDays(14), now()->subDays(7)])
            ->get();

        // Hitung rata-rata dependence score
        $avgDepCurrent = $last7->avg(fn($r) => $r->ml_result['digital_dependence_score'] ?? 0) ?? 0;
        $avgDepPrev    = $prev7->avg(fn($r) => $r->ml_result['digital_dependence_score'] ?? 0) ?? 0;

        $depChange = $avgDepPrev > 0
            ? round((($avgDepCurrent - $avgDepPrev) / $avgDepPrev) * 100, 1)
            : 0;

        // Simpan ke analytics_logs
        AnalyticsLog::create([
            'user_id'                      => $userId,
            'avg_dependence_7_days'        => round($avgDepCurrent, 2),
            'dependence_change_percentage' => $depChange,
            'created_at'                   => now(),
        ]);

        return response()->json([
            'success' => true,
            'data'    => [
                'period'                       => '7 hari terakhir',
                'avg_dependence_score'         => round($avgDepCurrent, 2),
                'dependence_change_percentage' => $depChange,
                'dependence_change_label'      => $this->changeLabel($depChange),
                'high_risk_days'               => $last7->filter(fn($r) =>
                    ($r->ml_result['category'] ?? '') === 'tinggi'
                )->count(),
                'total_surveys_week'           => $last7->count(),
                'daily_trend'                  => $last7->map(fn($r) => [
                    'date'             => Carbon::parse($r->created_at)->format('Y-m-d'),
                    'dependence_score' => $r->ml_result['digital_dependence_score'] ?? 0,
                    'category'         => $r->ml_result['category'] ?? 'rendah',
                    'confidence'       => $r->ml_result['confidence'] ?? 0,
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

        // Data user sendiri (terbaru)
        $myLatest = MlResult::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->first();

        // Rata-rata global (semua user, 30 hari terakhir)
        $global = MlResult::where('created_at', '>=', now()->subDays(30))->get();

        return response()->json([
            'success' => true,
            'data'    => [
                'my_scores' => $myLatest ? [
                    'dependence_score' => $myLatest->ml_result['digital_dependence_score'] ?? 0,
                    'category'         => $myLatest->ml_result['category'] ?? 'rendah',
                    'confidence'       => $myLatest->ml_result['confidence'] ?? 0,
                ] : null,
                'global_avg' => [
                    'dependence_score' => round(
                        $global->avg(fn($r) => $r->ml_result['digital_dependence_score'] ?? 0), 2
                    ),
                    'sample_size'      => $global->count(),
                ],
            ],
        ]);
    }

    /**
     * GET /api/analytics/history?days=30
     * History lengkap user untuk grafik di web/Flutter
     */
    public function history(Request $request): JsonResponse
    {
        $days = min((int) $request->get('days', 30), 90); // max 90 hari

        $results = MlResult::where('user_id', auth()->id())
            ->where('created_at', '>=', now()->subDays($days))
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => [
                'days'    => $days,
                'records' => $results->map(fn($r) => [
                    'date'             => Carbon::parse($r->created_at)->format('Y-m-d'),
                    'dependence_score' => $r->ml_result['digital_dependence_score'] ?? 0,
                    'category'         => $r->ml_result['category'] ?? 'rendah',
                    'confidence'       => $r->ml_result['confidence'] ?? 0,
                    'week_group'       => $r->week_group,
                ]),
            ],
        ]);
    }

    // ─── Private Helpers ─────────────────────────────────────

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