<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\MlResult;
use App\Models\Questionnaire;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class GrafikController extends Controller
{
    public function index(Request $request)
    {
        $userId = (string) Auth::id();
        $days = (int) $request->get('days', 7);

        $surveys = Questionnaire::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->take(min($days, 90))
            ->get()
            ->reverse()
            ->values()
            ->map(function($q) {
                $ml = MlResult::where('questionnaire_id', $q->_id)->first();
                $q->score = $ml ? ($ml->ml_result['digital_dependence_score'] ?? 0) : 0;
                return $q;
            });

        return view('web.grafik', compact('surveys', 'days'));
    }
}
