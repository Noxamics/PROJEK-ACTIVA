<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class KuesionerController extends Controller
{
    private function getRekomendasi(string $kategori): array
    {
        return match ($kategori) {
            'Sangat Tinggi' => [
                'Batasi penggunaan media sosial maksimal 1 jam per hari',
                'Aktifkan fitur screen time di perangkat',
                'Lakukan detoks digital minimal 1 hari per minggu',
                'Konsultasi dengan konselor kesehatan digital',
                'Tingkatkan aktivitas fisik dan waktu di luar ruangan',
            ],
            'Tinggi' => [
                'Atur jadwal penggunaan perangkat secara terstruktur',
                'Gunakan aplikasi pelacak waktu layar',
                'Prioritaskan interaksi langsung dengan orang sekitar',
                'Luangkan waktu untuk hobi offline',
                'Pastikan tidur cukup minimal 7 jam per malam',
            ],
            'Sedang' => [
                'Pertahankan keseimbangan digital yang ada',
                'Monitor penggunaan media sosial setiap minggu',
                'Tambah aktivitas fisik minimal 3 kali seminggu',
                'Kurangi notifikasi yang tidak penting',
                'Coba teknik mindfulness 10 menit per hari',
            ],
            default => [
                'Pertahankan gaya hidup digital yang sehat',
                'Jadilah contoh positif bagi orang sekitar',
                'Tetap aware terhadap perubahan kebiasaan digital',
                'Manfaatkan teknologi secara produktif',
            ],
        };
    }

    private function formatKategori(string $kategori): string
    {
        return match (strtolower($kategori)) {
            'sangat tinggi' => 'Sangat Tinggi',
            'tinggi'        => 'Tinggi',
            'sedang'        => 'Sedang',
            default         => 'Rendah',
        };
    }

    private function formatPendapatan(?string $income): string
    {
        return match (strtolower($income ?? '')) {
            'low'    => '< 3 Juta',
            'medium' => '3-7 Juta',
            'high'   => '> 7 Juta',
            default  => '-',
        };
    }

    private function formatRole(?string $role): string
    {
        return match (strtolower($role ?? '')) {
            'student'    => 'Mahasiswa',
            'worker'     => 'Pekerja',
            'housewife'  => 'Ibu Rumah Tangga',
            'freelancer' => 'Wiraswasta',
            default      => $role ?? '-',
        };
    }

    private function formatKualitasTidur(?int $val): string
    {
        return match (true) {
            $val >= 5   => 'Sangat Baik',
            $val === 4  => 'Baik',
            $val === 3  => 'Cukup',
            $val === 2  => 'Buruk',
            default     => 'Sangat Buruk',
        };
    }

    private function formatStres(?int $val): string
    {
        return match (true) {
            $val >= 9  => 'Sangat Tinggi',
            $val >= 7  => 'Tinggi',
            $val >= 5  => 'Sedang',
            $val >= 3  => 'Rendah',
            default    => 'Sangat Rendah',
        };
    }

    public function index()
    {
        $mlCol   = DB::connection('mongodb')->collection('ml_results');
        $userCol = DB::connection('mongodb')->collection('users');
        $qCol    = DB::connection('mongodb')->collection('questionnaires');

        // Ambil semua data
        $mlResults     = $mlCol->get()->keyBy(fn($r) => (string) $r['user_id']);
        $questionnaires = $qCol->get()->keyBy(fn($q) => (string) $q['user_id']);
        $users         = $userCol->get();

        $kuesioner = [];
        $no = 1;

        foreach ($users as $user) {
            $userId = (string) $user['_id'];
            $ml     = $mlResults->get($userId);
            $q      = $questionnaires->get($userId);

            if (!$ml || !$q) continue;

            $mlData   = json_decode($ml['ml_result'] ?? '{}', true);
            $skor     = (int) round($mlData['digital_dependence_score'] ?? 0);
            $kategori = $this->formatKategori($mlData['category'] ?? 'rendah');

            $kuesioner[] = [
                'user_id'               => 'USR-' . str_pad($no, 3, '0', STR_PAD_LEFT),
                'skor_ketergantungan'   => $skor,
                'kategori'              => $kategori,
                'gender'                => $user['gender'] ?? '-',
                'umur'                  => $user['age'] ?? '-',
                'region'                => $user['region'] ?? '-',
                'tingkat_pendidikan'    => $user['education_level'] ?? '-',
                'peran_harian'          => $this->formatRole($user['daily_role'] ?? null),
                'tingkat_pendapatan'    => $this->formatPendapatan($user['income_level'] ?? null),
                'jam_perangkat_per_hari'=> $q['device_hours_per_day'] ?? 0,
                'buka_hp_per_hari'      => $q['phone_unlocks'] ?? 0,
                'notifikasi_per_hari'   => $q['notifications_per_day'] ?? 0,
                'menit_medsos'          => $q['social_media_mins'] ?? 0,
                'menit_belajar'         => $q['study_minutes'] ?? 0,
                'hari_aktif_fisik'      => $q['physical_activity_days'] ?? 0,
                'jam_tidur'             => $q['sleep_hours'] ?? 0,
                'kualitas_tidur'        => $this->formatKualitasTidur($q['sleep_quality'] ?? null),
                'skor_kecemasan'        => $q['anxiety_score'] ?? 0,
                'skor_depresi'          => $q['depression_score'] ?? 0,
                'tingkat_stres'         => $this->formatStres($q['stress_level'] ?? null),
                'skor_kebahagiaan'      => $q['happiness_score'] ?? 0,
                'jenis_perangkat'       => $q['device_type'] ?? '-',
                'rekomendasi'           => $this->getRekomendasi($kategori),
            ];

            $no++;
        }

        // Ambil nilai unik untuk filter
        $regions = $users->pluck('region')->filter()->unique()->values()->toArray();
        $roles   = $users->pluck('daily_role')
                         ->filter()
                         ->unique()
                         ->map(fn($r) => $this->formatRole($r))
                         ->values()
                         ->toArray();

        return view('admin.kuesioner', compact('kuesioner', 'regions', 'roles'));
    }
}