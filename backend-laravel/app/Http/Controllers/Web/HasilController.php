<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\MlResult;
use App\Models\Questionnaire;
use Illuminate\Support\Facades\Auth;

class HasilController extends Controller
{
    public function show($id)
    {
        $q = Questionnaire::findOrFail($id);
        if ($q->user_id !== (string) Auth::id()) abort(403);

        $ml = MlResult::where('questionnaire_id', $q->_id)->first();

        return view('web.hasil', compact('q', 'ml'));
    }
}
