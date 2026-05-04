<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Admin;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        $mlCollection    = DB::connection('mongodb')->collection('ml_results');
        $userCollection  = DB::connection('mongodb')->collection('users');
        $qCollection     = DB::connection('mongodb')->collection('questionnaires');

        // ── Helper: parse ml_result string ────────────────────
        $parseScore = fn($doc) => json_decode($doc['ml_result'] ?? '{}', true);

        // ── Ambil semua ml_results ─────────────────────────────
        $allResults = $mlCollection->get()->map(function ($doc) use ($parseScore) {
            $ml = $parseScore($doc);
            return [
                'user_id'    => (string) $doc['user_id'],
                'score'      => (float) ($ml['digital_dependence_score'] ?? 0),
                'category'   => strtolower($ml['category'] ?? 'rendah'),
                'created_at' => isset($doc['created_at'])
                    ? Carbon::instance($doc['created_at']->toDateTime())
                    : Carbon::now(),
                'week_group' => $doc['week_group'] ?? null,
            ];
        });

        // ── Stats ──────────────────────────────────────────────
        $totalUsers  = $userCollection->count();
        $totalAdmins = Admin::count();
        $avgScore    = round($allResults->avg('score'), 1);
        $highRisk    = $allResults->where('category', 'tinggi')->count();

        $stats = [
            'total_users'  => $totalUsers,
            'total_admins' => $totalAdmins,
            'avg_focus'    => $avgScore,
            'avg_screen'   => 4.2,
            'high_risk'    => $highRisk,
        ];

        // ── 1. Distribusi Risk Level (Donut) ───────────────────
        $total  = $allResults->count() ?: 1;
        $rendah = $allResults->where('category', 'rendah')->count();
        $sedang = $allResults->where('category', 'sedang')->count();
        $tinggi = $allResults->where('category', 'tinggi')->count();

        $riskDist = [
            ['label' => 'Rendah', 'pct' => round($rendah / $total * 100), 'count' => $rendah, 'color' => 'teal'],
            ['label' => 'Sedang', 'pct' => round($sedang / $total * 100), 'count' => $sedang, 'color' => 'amber'],
            ['label' => 'Tinggi', 'pct' => round($tinggi / $total * 100), 'count' => $tinggi, 'color' => 'red'],
        ];

        // ── 2. Rata-rata Skor Trend (Harian/Mingguan/Bulanan) ──
        $dailyLabels = [];
        $dailyData   = [];
        $dayNames    = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
        for ($i = 6; $i >= 0; $i--) {
            $date   = Carbon::now()->subDays($i);
            $dayKey = $date->format('Y-m-d');
            $scores = $allResults->filter(fn($r) => $r['created_at']->format('Y-m-d') === $dayKey);
            $dailyLabels[] = $dayNames[$date->dayOfWeek];
            $dailyData[]   = $scores->count() ? round($scores->avg('score'), 1) : 0;
        }

        $weeklyLabels = [];
        $weeklyData   = [];
        for ($i = 3; $i >= 0; $i--) {
            $weekStart = Carbon::now()->subWeeks($i)->startOfWeek();
            $weekEnd   = (clone $weekStart)->endOfWeek();
            $scores    = $allResults->filter(fn($r) =>
                $r['created_at']->between($weekStart, $weekEnd)
            );
            $weeklyLabels[] = 'Mg ' . (4 - $i);
            $weeklyData[]   = $scores->count() ? round($scores->avg('score'), 1) : 0;
        }

        $monthlyLabels = [];
        $monthlyData   = [];
        $monthNames    = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
        for ($i = 5; $i >= 0; $i--) {
            $month  = Carbon::now()->subMonths($i);
            $scores = $allResults->filter(fn($r) =>
                $r['created_at']->format('Y-m') === $month->format('Y-m')
            );
            $monthlyLabels[] = $monthNames[$month->month - 1];
            $monthlyData[]   = $scores->count() ? round($scores->avg('score'), 1) : 0;
        }

        $scoreTrend = [
            'daily'   => ['labels' => $dailyLabels,   'data' => $dailyData],
            'weekly'  => ['labels' => $weeklyLabels,  'data' => $weeklyData],
            'monthly' => ['labels' => $monthlyLabels, 'data' => $monthlyData],
        ];

        // ── 3. Perbandingan Berdasarkan Kategori ───────────────
        $allUsers = $userCollection->get()->keyBy(fn($u) => (string) $u['_id']);

        $buildGroup = function ($groupField, $labelMap) use ($allResults, $allUsers) {
            $groups = [];
            foreach ($labelMap as $key => $label) {
                $filtered = $allResults->filter(function ($r) use ($allUsers, $groupField, $key) {
                    $user = $allUsers->get($r['user_id']);
                    if (!$user) return false;
                    return strtolower($user[$groupField] ?? '') === strtolower($key);
                });
                $groupTotal = $filtered->count() ?: 1;
                $groups[$label] = [
                    'rendah' => round($filtered->where('category', 'rendah')->count() / $groupTotal * 100),
                    'sedang' => round($filtered->where('category', 'sedang')->count() / $groupTotal * 100),
                    'tinggi' => round($filtered->where('category', 'tinggi')->count() / $groupTotal * 100),
                ];
            }
            return $groups;
        };

        $byRole = $buildGroup('daily_role', [
            'Student' => 'Mahasiswa',
            'Worker'  => 'Pekerja',
            'Other'   => 'Lainnya',
        ]);

        $byGender = $buildGroup('gender', [
            'Male'   => 'Laki-laki',
            'Female' => 'Perempuan',
        ]);

        $groupedBar = [
            'byRole' => [
                'labels' => array_keys($byRole),
                'rendah' => array_column(array_values($byRole), 'rendah'),
                'sedang' => array_column(array_values($byRole), 'sedang'),
                'tinggi' => array_column(array_values($byRole), 'tinggi'),
            ],
            'byGender' => [
                'labels' => array_keys($byGender),
                'rendah' => array_column(array_values($byGender), 'rendah'),
                'sedang' => array_column(array_values($byGender), 'sedang'),
                'tinggi' => array_column(array_values($byGender), 'tinggi'),
            ],
        ];

        // ── 4. Kuesioner Terisi per Hari ───────────────────────
        $submissionLabels = [];
        $submissionData   = [];
        for ($i = 6; $i >= 0; $i--) {
            $date               = Carbon::now()->subDays($i);
            $dayKey             = $date->format('Y-m-d');
            $count              = $qCollection->whereDate('created_at', $dayKey)->count();
            $submissionLabels[] = $date->format('d M');
            $submissionData[]   = $count;
        }

        $dailySubmissions = [
            'labels' => $submissionLabels,
            'data'   => $submissionData,
        ];

        // ── 5. Distribusi Skor (Histogram) ─────────────────────
        $histBuckets = [
            '0–9'    => [0, 9],
            '10–19'  => [10, 19],
            '20–29'  => [20, 29],
            '30–39'  => [30, 39],
            '40–49'  => [40, 49],
            '50–59'  => [50, 59],
            '60–69'  => [60, 69],
            '70–79'  => [70, 79],
            '80–89'  => [80, 89],
            '90–100' => [90, 100],
        ];

        $histData = [];
        foreach ($histBuckets as $label => [$min, $max]) {
            $histData[] = $allResults->filter(fn($r) =>
                $r['score'] >= $min && $r['score'] <= $max
            )->count();
        }

        $scoreHistogram = [
            'labels' => array_keys($histBuckets),
            'data'   => $histData,
        ];

        // ── 6. Summary Insights ────────────────────────────────
        $dominantCategory = collect([
            'Rendah' => $rendah,
            'Sedang' => $sedang,
            'Tinggi' => $tinggi,
        ])->sortDesc()->keys()->first();

        $dominantPct = round(max($rendah, $sedang, $tinggi) / $total * 100);

        $summaryInsights = [
            ['icon' => '📊', 'type' => 'info',    'text' => "Mayoritas user berada di kategori {$dominantCategory} ({$dominantPct}%)"],
            ['icon' => '📈', 'type' => 'up',      'text' => 'Rata-rata skor: ' . $avgScore],
            ['icon' => '⚠️', 'type' => 'warning', 'text' => 'Penggunaan device berlebih berkorelasi dengan skor tinggi'],
            ['icon' => '🔴', 'type' => 'danger',  'text' => "{$highRisk} user masuk kategori High Risk, perlu perhatian segera"],
        ];

        // ── 7. Threshold ───────────────────────────────────────
        $thresholds = [
            ['label' => 'Rendah', 'range' => '0 – 39',   'color' => 'teal',  'desc' => 'Ketergantungan digital masih dalam batas normal'],
            ['label' => 'Sedang', 'range' => '40 – 69',  'color' => 'amber', 'desc' => 'Mulai menunjukkan pola penggunaan yang berlebihan'],
            ['label' => 'Tinggi', 'range' => '70 – 100', 'color' => 'red',   'desc' => 'Ketergantungan digital sudah pada level mengkhawatirkan'],
        ];

        return view('admin.dashboard', compact(
            'stats',
            'riskDist',
            'scoreTrend',
            'groupedBar',
            'dailySubmissions',
            'scoreHistogram',
            'summaryInsights',
            'thresholds',
        ));
    }
}