<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\MlResult;
use App\Models\Questionnaire;
use Illuminate\Support\Facades\Auth;

class LaporanController extends Controller
{
    public function index()
    {
        $userId = (string) Auth::id();
        $all = Questionnaire::where('user_id', $userId)->orderBy('created_at', 'desc')->get();
        $totalCount = $all->count();

        if ($totalCount < 14) {
            return view('web.laporan', ['locked' => true, 'totalCount' => $totalCount]);
        }

        $current7 = $all->take(7);
        $prev7 = $all->slice(7, 7);

        $getAvg = fn($items, $key) => $items->avg(fn($q) => $q->{$key} ?? 0);

        $getScoreAvg = function($items) {
            return $items->avg(function($q) {
                $ml = MlResult::where('questionnaire_id', $q->_id)->first();
                return $ml ? ($ml->ml_result['digital_dependence_score'] ?? 0) : 0;
            });
        };

        $change = fn($curr, $prev) => $prev > 0 ? round(($curr - $prev) / $prev * 100, 1) : 0;

        $currScore = $getScoreAvg($current7);
        $prevScore = $getScoreAvg($prev7);

        $insights = [
            'dependensi' => ['current' => round($currScore, 1), 'previous' => round($prevScore, 1), 'change' => $change($currScore, $prevScore)],
            'screen_time' => ['current' => round($getAvg($current7, 'device_hours_per_day'), 1), 'previous' => round($getAvg($prev7, 'device_hours_per_day'), 1), 'change' => $change($getAvg($current7, 'device_hours_per_day'), $getAvg($prev7, 'device_hours_per_day'))],
            'social_media' => ['current' => round($getAvg($current7, 'social_media_mins'), 0), 'previous' => round($getAvg($prev7, 'social_media_mins'), 0), 'change' => $change($getAvg($current7, 'social_media_mins'), $getAvg($prev7, 'social_media_mins'))],
            'tidur' => ['current' => round($getAvg($current7, 'sleep_hours'), 1), 'previous' => round($getAvg($prev7, 'sleep_hours'), 1), 'change' => $change($getAvg($current7, 'sleep_hours'), $getAvg($prev7, 'sleep_hours'))],
            'stres' => ['current' => round($getAvg($current7, 'stress_level'), 1), 'previous' => round($getAvg($prev7, 'stress_level'), 1), 'change' => $change($getAvg($current7, 'stress_level'), $getAvg($prev7, 'stress_level'))],
        ];

        $status = $currScore < $prevScore ? 'membaik' : ($currScore > $prevScore ? 'memburuk' : 'stabil');

        // Top causes from all 14 data
        $causeCounts = [];
        $all->take(14)->each(function ($q) use (&$causeCounts) {
            $ml = MlResult::where('questionnaire_id', $q->_id)->first();
            $causes = $ml ? ($ml->ai_analysis['penyebab'] ?? []) : [];
            foreach ($causes as $c) { $causeCounts[$c] = ($causeCounts[$c] ?? 0) + 1; }
        });
        arsort($causeCounts);
        $topCauses = array_slice($causeCounts, 0, 3, true);

        return view('web.laporan', compact('insights', 'status', 'topCauses', 'totalCount') + ['locked' => false]);
    }
}
