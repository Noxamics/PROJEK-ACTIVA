<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ExportCenterController extends Controller
{
    public function index()
    {
        $userCount = DB::connection('mongodb')->collection('users')->count();

        // Hitung kuesioner yang sudah punya hasil ML (konsisten dengan halaman Data Kuesioner)
        // Gunakan unique() agar user_id duplikat tidak dihitung lebih dari sekali
        $mlUserIds = DB::connection('mongodb')->collection('ml_results')->pluck('user_id')->map(fn($id) => (string) $id)->unique();
        $qUserIds = DB::connection('mongodb')->collection('questionnaires')->pluck('user_id')->map(fn($id) => (string) $id)->unique();
        $kuesionerCount = $mlUserIds->intersect($qUserIds)->count();

        return view('admin.export', compact('userCount', 'kuesionerCount'));
    }

    public function download(Request $request)
    {
        $type = $request->query('type', 'users');
        $filename = 'activa_' . $type . '_' . date('Y-m-d_His') . '.csv';

        $response = new StreamedResponse(function () use ($type) {
            $handle = fopen('php://output', 'w');
            // UTF-8 BOM for Excel compatibility
            fprintf($handle, chr(0xEF) . chr(0xBB) . chr(0xBF));

            if ($type === 'users') {
                $this->exportUsers($handle);
            } else {
                $this->exportKuesioner($handle);
            }

            fclose($handle);
        });

        $response->headers->set('Content-Type', 'text/csv; charset=UTF-8');
        $response->headers->set('Content-Disposition', 'attachment; filename="' . $filename . '"');

        return $response;
    }

    private function exportUsers($handle)
    {
        fputcsv($handle, [
            'No', 'Nama', 'Email', 'Gender', 'Umur', 'Region',
            'Pendidikan', 'Peran', 'Pendapatan', 'Tanggal Daftar',
        ]);

        $users = DB::connection('mongodb')->collection('users')->get();
        $no = 1;

        foreach ($users as $user) {
            $age = '-';
            if (isset($user['date_of_birth'])) {
                try {
                    $dob = $user['date_of_birth'];
                    if ($dob instanceof \MongoDB\BSON\UTCDateTime) {
                        $age = Carbon::parse($dob->toDateTime())->age;
                    } else {
                        $age = Carbon::parse($dob)->age;
                    }
                } catch (\Exception $e) {
                    $age = '-';
                }
            }

            $createdAt = '-';
            if (isset($user['created_at'])) {
                try {
                    $ca = $user['created_at'];
                    if ($ca instanceof \MongoDB\BSON\UTCDateTime) {
                        $createdAt = Carbon::parse($ca->toDateTime())->format('d/m/Y H:i');
                    } else {
                        $createdAt = Carbon::parse($ca)->format('d/m/Y H:i');
                    }
                } catch (\Exception $e) {
                    $createdAt = '-';
                }
            }

            fputcsv($handle, [
                $no++,
                $user['name'] ?? '-',
                $user['email'] ?? '-',
                $user['gender'] ?? '-',
                $age,
                $user['region'] ?? '-',
                $user['education_level'] ?? '-',
                $user['daily_role'] ?? '-',
                $user['income_level'] ?? '-',
                $createdAt,
            ]);
        }
    }

    private function exportKuesioner($handle)
    {
        fputcsv($handle, [
            'No', 'User ID', 'Skor Ketergantungan', 'Kategori',
            'Jam Perangkat/Hari', 'Buka HP/Hari', 'Notifikasi/Hari',
            'Menit Medsos', 'Menit Belajar', 'Hari Aktivitas Fisik',
            'Jam Tidur', 'Kualitas Tidur', 'Skor Kecemasan',
            'Skor Depresi', 'Tingkat Stres', 'Skor Kebahagiaan',
        ]);

        $mlResults = DB::connection('mongodb')->collection('ml_results')->get()->keyBy(fn($r) => (string) $r['user_id']);
        $questionnaires = DB::connection('mongodb')->collection('questionnaires')->get()->keyBy(fn($q) => (string) $q['user_id']);
        $users = DB::connection('mongodb')->collection('users')->get();
        $no = 1;

        foreach ($users as $user) {
            $userId = (string) $user['_id'];
            $ml = $mlResults->get($userId);
            $q = $questionnaires->get($userId);

            if (!$ml || !$q) continue;

            $mlData = json_decode($ml['ml_result'] ?? '{}', true);
            $skor = (int) round($mlData['digital_dependence_score'] ?? 0);
            $kategori = $mlData['category'] ?? '-';

            fputcsv($handle, [
                $no++,
                'USR-' . str_pad($no - 1, 3, '0', STR_PAD_LEFT),
                $skor,
                $kategori,
                $q['device_hours_per_day'] ?? 0,
                $q['phone_unlocks'] ?? 0,
                $q['notifications_per_day'] ?? 0,
                $q['social_media_mins'] ?? 0,
                $q['study_minutes'] ?? 0,
                $q['physical_activity_days'] ?? 0,
                $q['sleep_hours'] ?? 0,
                $q['sleep_quality'] ?? 0,
                $q['anxiety_score'] ?? 0,
                $q['depression_score'] ?? 0,
                $q['stress_level'] ?? 0,
                $q['happiness_score'] ?? 0,
            ]);
        }
    }
}
