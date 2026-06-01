<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\MlResult;
use App\Models\Questionnaire;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class GrafikController extends Controller
{
    public function index(Request $request)
    {
        $userId = (string) Auth::id();
        $mode   = $request->get('mode', 'week'); // week | month | year

        $selectedYear  = (int) $request->get('year',  now()->year);
        $selectedMonth = (int) $request->get('month', now()->month);

        $query = Questionnaire::where('user_id', $userId);

        if ($mode === 'week') {
            $query->where('created_at', '>=', Carbon::now()->subDays(7));

        } elseif ($mode === 'month') {
            $start = Carbon::create($selectedYear, $selectedMonth, 1)->startOfMonth();
            $end   = $start->copy()->endOfMonth();
            $query->where('created_at', '>=', $start)
                  ->where('created_at', '<=', $end);

        } elseif ($mode === 'year') {
            $start = Carbon::create($selectedYear, 1, 1)->startOfYear();
            $end   = $start->copy()->endOfYear();
            $query->where('created_at', '>=', $start)
                  ->where('created_at', '<=', $end);
        }

        $surveys = $query->orderBy('created_at', 'asc')->get()
            ->map(function ($q) {
                $ml = MlResult::where('questionnaire_id', $q->_id)->first();
                $q->score = $ml ? ($ml->ml_result['digital_dependence_score'] ?? 0) : 0;
                return $q;
            });

        // Available years: derive from all user data (PHP side, MongoDB compatible)
        $allDates = Questionnaire::where('user_id', $userId)
            ->orderBy('created_at', 'asc')
            ->get(['created_at']);

        $availableYears = $allDates
            ->filter(fn($q) => !is_null($q->created_at))
            ->map(fn($q) => (int) $q->created_at->format('Y'))
            ->unique()
            ->sortDesc()
            ->values();

        if ($availableYears->isEmpty()) {
            $availableYears = collect([now()->year]);
        }

        $months = [
            1=>'Januari',2=>'Februari',3=>'Maret',4=>'April',
            5=>'Mei',6=>'Juni',7=>'Juli',8=>'Agustus',
            9=>'September',10=>'Oktober',11=>'November',12=>'Desember',
        ];

        // For year mode: group by month and build monthly aggregates
        $overrideLabels = $overrideScores = $overrideScreen = $overrideSocial = $overrideSleep = [];
        if ($mode === 'year') {
            $grouped = $surveys->groupBy(fn($s) => $s->created_at ? (int)$s->created_at->format('n') : 0);
            for ($m = 1; $m <= 12; $m++) {
                $overrideLabels[] = substr($months[$m], 0, 3);
                $group = $grouped->get($m, collect());
                $overrideScores[] = $group->count() ? round($group->avg(fn($s) => $s->score ?? 0), 1) : null;
                $overrideScreen[] = $group->count() ? round($group->avg(fn($s) => $s->device_hours_per_day ?? 0), 1) : null;
                $overrideSocial[] = $group->count() ? round($group->avg(fn($s) => $s->social_media_mins ?? 0)) : null;
                $overrideSleep[]  = $group->count() ? round($group->avg(fn($s) => $s->sleep_quality ?? 0), 1) : null;
            }
        }

        $days = $mode; // backward compat alias

        return view('web.grafik', compact(
            'surveys', 'mode', 'months', 'days',
            'availableYears', 'selectedYear', 'selectedMonth',
            'overrideLabels', 'overrideScores', 'overrideScreen', 'overrideSocial', 'overrideSleep'
        ));
    }
}
