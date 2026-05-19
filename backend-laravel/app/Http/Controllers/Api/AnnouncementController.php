<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AnnouncementController extends Controller
{
    /**
     * GET /api/announcements
     * Ambil daftar pengumuman untuk mobile app
     */
    public function index(): JsonResponse
    {
        try {
            $announcements = DB::connection('mongodb')
                ->collection('announcements')
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($item) {
                    $item['id'] = (string) $item['_id'];
                    unset($item['_id']);
                    
                    $ca = $item['created_at'] ?? null;
                    if ($ca instanceof \MongoDB\BSON\UTCDateTime) {
                        $dt = $ca->toDateTime();
                        $item['created_at'] = $dt->format('Y-m-d H:i:s');
                        $item['date_human'] = Carbon::parse($dt)->diffForHumans();
                    }
                    
                    return $item;
                });

            return response()->json([
                'success' => true,
                'data'    => $announcements,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil pengumuman: ' . $e->getMessage(),
            ], 500);
        }
    }
}
