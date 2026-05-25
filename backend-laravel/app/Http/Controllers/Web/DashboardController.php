<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\MlResult;
use App\Models\Questionnaire;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        $userId = (string) $user->_id;

        // Latest survey
        $latestQ = Questionnaire::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->first();

        // Get ML result for latest
        $latestMl = null;
        if ($latestQ) {
            $latestMl = MlResult::where('questionnaire_id', $latestQ->_id)->first();
        }

        // Weekly insight (avg last 7)
        $last7Q = Questionnaire::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->take(7)->get();

        $avgScore = null;
        $changePercent = null;
        if ($last7Q->count() >= 2) {
            $scores = $last7Q->map(function($q) {
                $ml = MlResult::where('questionnaire_id', $q->_id)->first();
                return $ml ? ($ml->ml_result['digital_dependence_score'] ?? 0) : null;
            })->filter();

            $avgScore = $scores->count() > 0 ? round($scores->avg(), 1) : null;

            $prev7Q = Questionnaire::where('user_id', $userId)
                ->orderBy('created_at', 'desc')
                ->skip(7)->take(7)->get();
            if ($prev7Q->count() > 0) {
                $prevScores = $prev7Q->map(function($q) {
                    $ml = MlResult::where('questionnaire_id', $q->_id)->first();
                    return $ml ? ($ml->ml_result['digital_dependence_score'] ?? 0) : null;
                })->filter();
                $prevAvg = $prevScores->count() > 0 ? $prevScores->avg() : null;
                if ($prevAvg && $prevAvg > 0) {
                    $changePercent = round((($avgScore - $prevAvg) / $prevAvg) * 100, 1);
                }
            }
        }

        $totalKuesioner = Questionnaire::where('user_id', $userId)->count();

        // Calculate Streak
        $dates = Questionnaire::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get(['created_at'])
            ->map(function ($q) {
                return $q->created_at->timezone('Asia/Jakarta')->format('Y-m-d');
            })
            ->unique()
            ->values()
            ->toArray();

        $streak = 0;
        if (!empty($dates)) {
            $today = \Carbon\Carbon::now('Asia/Jakarta')->format('Y-m-d');
            $yesterday = \Carbon\Carbon::now('Asia/Jakarta')->subDay()->format('Y-m-d');
            
            if ($dates[0] === $today || $dates[0] === $yesterday) {
                $streak = 1;
                $currentDate = \Carbon\Carbon::parse($dates[0]);
                
                for ($i = 1; $i < count($dates); $i++) {
                    $prevDate = $currentDate->copy()->subDay()->format('Y-m-d');
                    if ($dates[$i] === $prevDate) {
                        $streak++;
                        $currentDate->subDay();
                    } else {
                        break;
                    }
                }
            }
        }

        return view('web.dashboard', compact('user', 'latestQ', 'latestMl', 'avgScore', 'changePercent', 'totalKuesioner', 'streak'));
    }
}
