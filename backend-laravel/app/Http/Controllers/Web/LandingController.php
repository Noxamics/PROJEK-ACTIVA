<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class LandingController extends Controller
{
    public function index()
    {


        // Count registered users
        $userCount = DB::connection('mongodb')->collection('users')->count();

        // Count questionnaires
        $surveyCount = DB::connection('mongodb')->collection('questionnaires')->count();

        return view('web.landing', compact('userCount', 'surveyCount'));
    }
}
