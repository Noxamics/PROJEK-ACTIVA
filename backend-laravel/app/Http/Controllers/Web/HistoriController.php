<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\MlResult;
use App\Models\Questionnaire;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class HistoriController extends Controller
{
    public function index(Request $request)
    {
        $userId = (string) Auth::id();
        $sort = $request->get('sort', 'terbaru');

        $query = Questionnaire::where('user_id', $userId);

        switch ($sort) {
            case 'terlama': $query->orderBy('created_at', 'asc'); break;
            default: $query->orderBy('created_at', 'desc');
        }

        $surveys = $query->get()->map(function($q) {
            $ml = MlResult::where('questionnaire_id', $q->_id)->first();
            $q->score = $ml ? ($ml->ml_result['digital_dependence_score'] ?? 0) : 0;
            $q->category = $ml ? ($ml->ml_result['category'] ?? 'rendah') : 'rendah';
            return $q;
        });

        // Sort by score if needed
        if ($sort === 'tertinggi') $surveys = $surveys->sortByDesc('score')->values();
        if ($sort === 'terendah') $surveys = $surveys->sortBy('score')->values();

        return view('web.histori', compact('surveys', 'sort'));
    }
}
