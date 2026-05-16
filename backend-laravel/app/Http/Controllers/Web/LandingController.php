<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class LandingController extends Controller
{
    public function index()
    {
        // Fetch announcements from MongoDB (same collection as admin)
        $announcements = DB::connection('mongodb')
            ->collection('announcements')
            ->orderBy('created_at', 'desc')
            ->limit(10)
            ->get()
            ->map(function ($item) {
                $ca = $item['created_at'] ?? null;
                if ($ca instanceof \MongoDB\BSON\UTCDateTime) {
                    $item['created_at_formatted'] = Carbon::parse($ca->toDateTime())->format('d M Y');
                    $item['created_at_relative']  = Carbon::parse($ca->toDateTime())->diffForHumans();
                } elseif ($ca) {
                    $item['created_at_formatted'] = Carbon::parse($ca)->format('d M Y');
                    $item['created_at_relative']  = Carbon::parse($ca)->diffForHumans();
                } else {
                    $item['created_at_formatted'] = '-';
                    $item['created_at_relative']  = '-';
                }
                return $item;
            });

        // Count registered users
        $userCount = DB::connection('mongodb')->collection('users')->count();

        // Count questionnaires
        $surveyCount = DB::connection('mongodb')->collection('questionnaires')->count();

        return view('web.landing', compact('announcements', 'userCount', 'surveyCount'));
    }
}
