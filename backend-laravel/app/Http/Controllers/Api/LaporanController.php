<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\MlResult;        // sesuaikan namespace model kamu
use App\Models\Questionnaire;   // sesuaikan namespace model kamu

class LaporanController extends Controller
{
    /**
     * Ambil 14 ml_result terbaru milik user,
     * split jadi dua grup 7, lalu hitung perbandingan.
     */
    public function getLaporan(Request $request)
    {
        $userId = Auth::id();

        // ── 1. Ambil 14 ml_result terbaru ──────────────────────────────────
        // Asumsi: ml_results punya relasi ke questionnaires lewat questionnaire_id
        // dan questionnaires punya field created_at untuk urutan waktu
        $results = MlResult::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->limit(14)
            ->get();

        // Harus ada minimal 14 data
        if ($results->count() < 14) {
            return response()->json([
                'success' => false,
                'message' => 'Data belum cukup. Isi kuesioner lebih banyak.',
                'count'   => $results->count(),
            ], 422);
        }

        // ── 2. Split: 7 terbaru = "minggu ini", 7 berikutnya = "minggu lalu"
        // collect() sudah desc, jadi index 0-6 = terbaru
        $thisWeek = $results->slice(0, 7);   // 7 terbaru
        $lastWeek = $results->slice(7, 7);   // 7 sebelumnya

        // ── 3. Hitung rata-rata score ───────────────────────────────────────
        $thisScore = $thisWeek->avg(fn($r) => $r->ml_result['digital_dependence_score'] ?? 0);
        $lastScore = $lastWeek->avg(fn($r) => $r->ml_result['digital_dependence_score'] ?? 0);

        $scoreDiff   = $thisScore - $lastScore;
        $scorePct    = $lastScore > 0 ? round(($scoreDiff / $lastScore) * 100, 1) : 0;
        $scoreStatus = $scoreDiff > 2 ? 'memburuk' : ($scoreDiff < -2 ? 'membaik' : 'stabil');

        // ── 4. Ambil questionnaire data untuk insight lain ──────────────────
        // Kita butuh questionnaire_id dari ml_results
        $thisQids = $thisWeek->pluck('questionnaire_id');
        $lastQids = $lastWeek->pluck('questionnaire_id');

        $thisQuestionnaires = Questionnaire::whereIn('_id', $thisQids)->get();
        $lastQuestionnaires = Questionnaire::whereIn('_id', $lastQids)->get();

        // Helper avg
        $avg = fn($col, $coll) => $coll->avg($col) ?? 0;

        // Screen time
        $thisDeviceHours = $avg('device_hours_per_day', $thisQuestionnaires);
        $lastDeviceHours = $avg('device_hours_per_day', $lastQuestionnaires);
        $deviceDiff      = round($thisDeviceHours - $lastDeviceHours, 1);

        // Social media
        $thisSocial   = $avg('social_media_minutes', $thisQuestionnaires);
        $lastSocial   = $avg('social_media_minutes', $lastQuestionnaires);
        $socialPct    = $lastSocial > 0 ? round((($thisSocial - $lastSocial) / $lastSocial) * 100, 1) : 0;

        // Sleep
        $thisSleepH   = $avg('sleep_hours', $thisQuestionnaires);
        $lastSleepH   = $avg('sleep_hours', $lastQuestionnaires);
        $thisSleepQ   = $avg('sleep_quality', $thisQuestionnaires);
        $lastSleepQ   = $avg('sleep_quality', $lastQuestionnaires);
        $sleepHDiff   = round($thisSleepH - $lastSleepH, 1);
        $sleepQDiff   = round($thisSleepQ - $lastSleepQ, 1);

        // Stress
        $thisStress   = $avg('stress_level', $thisQuestionnaires);
        $lastStress   = $avg('stress_level', $lastQuestionnaires);
        $stressPct    = $lastStress > 0 ? round((($thisStress - $lastStress) / $lastStress) * 100, 1) : 0;

        // ── 5. Bangun insight text ──────────────────────────────────────────
        $insights = [
            'digital_dependence' => $this->buildScoreInsight($scorePct, $scoreStatus),
            'screen_time'        => $this->buildScreenTimeInsight($deviceDiff, $thisDeviceHours, $lastDeviceHours),
            'social_media'       => $this->buildSocialInsight($socialPct),
            'sleep'              => $this->buildSleepInsight($sleepHDiff, $thisSleepQ, $lastSleepQ),
            'stress'             => $this->buildStressInsight($stressPct),
        ];

        // ── 6. Penyebab: tag paling sering muncul dari 14 data ─────────────
        $allTags = [];
        foreach ($results as $r) {
            $penyebab = $r->ai_analysis['penyebab'] ?? [];
            foreach ($penyebab as $tag) {
                $allTags[] = $tag;
            }
        }
        $tagCounts = array_count_values($allTags);
        arsort($tagCounts);
        $topTags = array_slice(array_keys($tagCounts), 0, 3); // 3 penyebab teratas

        // Format penyebab untuk display (ganti underscore jadi spasi, ucwords)
        $causesDisplay = array_map(fn($t) => ucwords(str_replace('_', ' ', $t)), $topTags);

        // ── 7. Rekomendasi: ambil dari ai_analysis terbaru berdasarkan topTag
        $rekomendasi = [];
        if (!empty($topTags)) {
            $latestResult = $results->first();
            $rekomendasiAll = $latestResult->ai_analysis['rekomendasi'] ?? [];
            foreach ($rekomendasiAll as $rek) {
                if (in_array($rek['tag'] ?? '', $topTags)) {
                    $rekomendasi[] = $rek['isi'];
                    break; // ambil 1 rekomendasi paling relevan
                }
            }
            // fallback: ambil rekomendasi pertama jika tidak ada yang cocok
            if (empty($rekomendasi) && !empty($rekomendasiAll)) {
                $rekomendasi[] = $rekomendasiAll[0]['isi'];
            }
        }

        // ── 8. Waktu data terakhir & info next report ───────────────────────
        $latestCreatedAt = $results->first()->created_at;
        $oldestInSet     = $results->last()->created_at;

        return response()->json([
            'success' => true,
            'data'    => [
                'status'         => $scoreStatus,           // membaik | memburuk | stabil
                'score_pct'      => $scorePct,              // % perubahan
                'this_week_avg'  => round($thisScore, 1),
                'last_week_avg'  => round($lastScore, 1),
                'insights'       => $insights,
                'causes'         => $causesDisplay,
                'recommendation' => $rekomendasi,
                'data_range'     => [
                    'newest' => $latestCreatedAt,
                    'oldest' => $oldestInSet,
                ],
                'total_data_used' => 14,
            ],
        ]);
    }

    // ── Insight builders ────────────────────────────────────────────────────

    private function buildScoreInsight(float $pct, string $status): string
    {
        $absPct = abs($pct);
        if ($status === 'memburuk') {
            return "Ketergantungan digital kamu meningkat {$absPct}% dalam 7 hari terakhir";
        } elseif ($status === 'membaik') {
            return "Kondisi kamu membaik {$absPct}% dibanding minggu lalu 🎉";
        }
        return "Ketergantungan digital kamu relatif stabil minggu ini";
    }

    private function buildScreenTimeInsight(float $diff, float $thisH, float $lastH): string
    {
        $absD = abs($diff);
        if ($diff > 0.5) {
            return "Waktu penggunaan device naik {$absD} jam/hari (dari {$lastH} → {$thisH} jam)";
        } elseif ($diff < -0.5) {
            return "Screen time turun {$absD} jam/hari 👍 (dari {$lastH} → {$thisH} jam)";
        }
        return "Screen time kamu tidak banyak berubah minggu ini";
    }

    private function buildSocialInsight(float $pct): string
    {
        $absPct = abs($pct);
        if ($pct > 5) {
            return "Penggunaan media sosial meningkat {$absPct}%";
        } elseif ($pct < -5) {
            return "Kamu lebih jarang membuka media sosial minggu ini ({$absPct}% turun) 👍";
        }
        return "Penggunaan media sosial kamu stabil minggu ini";
    }

    private function buildSleepInsight(float $hoursDiff, float $thisQ, float $lastQ): string
    {
        $absH = abs($hoursDiff);
        $qDiff = round($thisQ - $lastQ, 1);
        $parts = [];

        if ($hoursDiff < -0.3) {
            $parts[] = "Waktu tidur berkurang {$absH} jam";
        } elseif ($hoursDiff > 0.3) {
            $parts[] = "Waktu tidur bertambah {$absH} jam 👍";
        }

        if ($qDiff < -0.3) {
            $parts[] = "kualitas tidur menurun (dari " . round($lastQ, 1) . " → " . round($thisQ, 1) . ")";
        } elseif ($qDiff > 0.3) {
            $parts[] = "kualitas tidur membaik (dari " . round($lastQ, 1) . " → " . round($thisQ, 1) . ") 👍";
        }

        return empty($parts) ? "Pola tidur kamu stabil minggu ini" : implode(', ', $parts);
    }

    private function buildStressInsight(float $pct): string
    {
        $absPct = abs($pct);
        if ($pct > 5) {
            return "Tingkat stres meningkat {$absPct}%";
        } elseif ($pct < -5) {
            return "Stres kamu lebih rendah dibanding minggu lalu ({$absPct}% turun) 😊";
        }
        return "Tingkat stres kamu stabil minggu ini";
    }
}