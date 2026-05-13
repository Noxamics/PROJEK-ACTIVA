<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AnnouncementController extends Controller
{
    public function index()
    {
        $announcements = DB::connection('mongodb')
            ->collection('announcements')
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($item) {
                $ca = $item['created_at'] ?? null;
                if ($ca instanceof \MongoDB\BSON\UTCDateTime) {
                    $item['created_at_formatted'] = Carbon::parse($ca->toDateTime())->format('d M Y, H:i');
                } elseif ($ca) {
                    $item['created_at_formatted'] = Carbon::parse($ca)->format('d M Y, H:i');
                } else {
                    $item['created_at_formatted'] = '-';
                }
                return $item;
            });

        return view('admin.announcements', compact('announcements'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'title'   => 'required|string|max:200',
            'content' => 'required|string|max:2000',
            'type'    => 'required|in:info,warning,update',
        ]);

        DB::connection('mongodb')->collection('announcements')->insert([
            'title'      => $request->input('title'),
            'content'    => $request->input('content'),
            'type'       => $request->input('type'),
            'author'     => auth()->user()->name ?? 'Admin',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return redirect()->route('admin.announcements')->with('success', 'Pengumuman berhasil dibuat.');
    }

    public function destroy($id)
    {
        DB::connection('mongodb')->collection('announcements')->where('_id', $id)->delete();

        return redirect()->route('admin.announcements')->with('success', 'Pengumuman berhasil dihapus.');
    }
}
