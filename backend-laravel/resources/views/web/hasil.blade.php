@extends('web.layouts.app')
@section('title', 'Hasil Analisis')

@section('styles')
@section('body-class', 'page-histori')
<link href="{{ asset('css/user-web/histori.css') }}" rel="stylesheet">
<style>
    .hasil-card {
        background: rgba(255,255,255,0.06);
        border: 1px solid rgba(255,255,255,0.1);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        color: #fff;
        transition: transform 0.25s cubic-bezier(0.4,0,0.2,1), box-shadow 0.25s, border-color 0.25s;
    }
    .hasil-card:hover {
        transform: translateY(-4px);
        border-color: rgba(0,229,200,0.4);
        box-shadow: 0 12px 40px rgba(0,229,200,0.15), 0 4px 12px rgba(0,0,0,0.3);
    }
    .hasil-card h2, .hasil-card h3 { color: #fff; }
    .hasil-card p, .hasil-card div { color: rgba(255,255,255,0.85); }
    .hasil-cause-item, .hasil-rec-item {
        background: rgba(255,255,255,0.04) !important;
        border: 1px solid rgba(255,255,255,0.08);
        transition: transform 0.2s;
    }
    .hasil-cause-item:hover, .hasil-rec-item:hover {
        transform: translateX(4px);
        background: rgba(255,255,255,0.06) !important;
    }
</style>
@endsection

@section('content')

{{-- ── Dark background + decorative circles ── --}}
<div class="hist-bg"       aria-hidden="true"></div>
<div class="hist-orb-mid"  aria-hidden="true"></div>
<div class="hist-circle-1" aria-hidden="true"></div>
<div class="hist-circle-2" aria-hidden="true"></div>
<div class="hist-circle-3" aria-hidden="true"></div>
<div class="hist-circle-4" aria-hidden="true"></div>
<div class="hist-circle-5" aria-hidden="true"></div>
<div class="hist-circle-6" aria-hidden="true"></div>

@php
    $mlData = $ml ? ($ml->ml_result ?? []) : [];
    $aiData = $ml ? ($ml->ai_analysis ?? []) : [];
    $score = $mlData['digital_dependence_score'] ?? 0;
    $confRaw = $mlData['confidence'] ?? 0;
    $confidence = is_array($confRaw) ? ($confRaw['confidence_final_pct'] ?? 0) : (float)$confRaw;
    $category = $mlData['category'] ?? 'rendah';
    $causes = $aiData['penyebab'] ?? [];
    $rekom = $aiData['rekomendasi'] ?? [];
    $summary = $aiData['pembukaan'] ?? $aiData['summary'] ?? '';
    $scoreColor = $score < 33.47 ? '#22C55E' : ($score <= 61.34 ? '#F59E0B' : '#EF4444');
    $scoreCat = $score < 33.47 ? 'Rendah' : ($score <= 61.34 ? 'Sedang' : 'Tinggi');
    $scoreBadge = $score < 33.47 ? 'green' : ($score <= 61.34 ? 'amber' : 'red');
    $circ = 2 * 3.14159 * 85;
    $offset = $circ - ($score / 100) * $circ;
    
    $svgPhone = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#a855f7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="2" ry="2"></rect><line x1="12" y1="18" x2="12.01" y2="18"></line></svg>';
    $svgBell = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#f59e0b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>';
    $svgMoon = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>';
    $svgBed = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 4v16"></path><path d="M2 8h18a2 2 0 0 1 2 2v10"></path><path d="M2 17h20"></path><path d="M6 8v9"></path></svg>';
    $svgActivity = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"></path></svg>';
    $svgFrown = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><path d="M16 16s-1.5-2-4-2-4 2-4 2"></path><line x1="9" y1="9" x2="9.01" y2="9"></line><line x1="15" y1="9" x2="15.01" y2="9"></line></svg>';
    $svgZap = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg>';
    $svgMessage = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#0ea5e9" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>';
    $svgAlert = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#f59e0b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>';

    $causeLabels = [
        'screen_time_high' => [$svgPhone,'Screen Time Berlebihan','Penggunaan perangkat terlalu lama setiap hari'],
        'notification_overload' => [$svgBell,'Notifikasi Berlebihan','Terlalu banyak notifikasi mengganggu fokus'],
        'sleep_low' => [$svgMoon,'Kurang Tidur','Durasi tidur di bawah 7 jam yang ideal'],
        'sleep_bad_quality' => [$svgBed,'Kualitas Tidur Buruk','Kualitas tidur tidak optimal'],
        'anxiety_high' => [$svgActivity,'Kecemasan Tinggi','Tingkat kecemasan di atas normal'],
        'depression_high' => [$svgFrown,'Depresi Tinggi','Skor depresi mengkhawatirkan'],
        'stress_high' => [$svgZap,'Stres Tinggi','Tingkat stres perlu diwaspadai'],
        'happiness_low' => [$svgFrown,'Kebahagiaan Rendah','Tingkat kebahagiaan di bawah rata-rata'],
        'tidur_kurang' => [$svgMoon,'Kurang Tidur','Durasi tidur kurang dari ideal'],
        'screen_time_tinggi' => [$svgPhone,'Screen Time Tinggi','Penggunaan layar berlebihan'],
        'social_media_tinggi' => [$svgMessage,'Media Sosial Berlebihan','Penggunaan media sosial terlalu lama'],
    ];
@endphp

<div style="max-width:800px;margin:0 auto;position:relative;z-index:2;">
    <div class="hist-header anim-fade"><h1>Hasil Analisis</h1><p>{{ $q->created_at ? $q->created_at->format('d M Y, H:i') : '' }}</p></div>

    @if(!$ml)
    <div class="card hasil-card card-p-lg anim-up" style="text-align:center;">
        <div style="font-size:3rem;margin-bottom:12px;">⏳</div>
        <h2>Prediksi Belum Tersedia</h2>
        <p style="color:rgba(255,255,255,0.55);margin:12px 0;">ML service mungkin sedang tidak aktif. Silakan coba lagi nanti.</p>
        <a href="{{ url('/user/dashboard') }}" class="btn btn-primary">Kembali ke Dashboard</a>
    </div>
    @else
    {{-- Score --}}
    <div class="card hasil-card card-p-lg anim-up" style="text-align:center;margin-bottom:24px;">
        <div class="score-gauge" style="width:200px;height:200px;">
            <svg viewBox="0 0 200 200">
                <circle cx="100" cy="100" r="85" fill="none" stroke="{{ $scoreColor }}15" stroke-width="12"/>
                <circle cx="100" cy="100" r="85" fill="none" stroke="{{ $scoreColor }}" stroke-width="12" stroke-linecap="round"
                    stroke-dasharray="{{ $circ }}" stroke-dashoffset="{{ $offset }}" style="transition:stroke-dashoffset 1.5s cubic-bezier(.16,1,.3,1)"/>
            </svg>
            <div class="score-gauge-text">
                <div class="score-value" style="color:{{ $scoreColor }};">{{ round($score) }}</div>
                <div class="score-label" style="color:rgba(255,255,255,0.55)">dari 100</div>
            </div>
        </div>
        <span class="badge badge-{{ $scoreBadge }}" style="font-size:.875rem;padding:8px 20px;margin-top:16px;">Tingkat {{ $scoreCat }}</span>
    </div>

    {{-- AI Analysis --}}
    @if(!empty($summary))
    <div class="card hasil-card card-p anim-up d2" style="margin-bottom:24px;">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px;">
            <div style="width:40px;height:40px;border-radius:var(--radius-lg);background:rgba(168,85,247,.15);display:flex;align-items:center;justify-content:center;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#a855f7" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M12 1v2m0 18v2M4.22 4.22l1.42 1.42m12.72 12.72l1.42 1.42M1 12h2m18 0h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>
            </div>
            <h3>Analisis AI</h3>
        </div>
        <p style="color:rgba(255,255,255,0.7);font-size:.9375rem;line-height:1.8;">{{ $summary }}</p>
    </div>
    @endif

    {{-- Causes --}}
    @if(count($causes))
    <div class="card hasil-card card-p anim-up d3" style="margin-bottom:24px;">
        <h3 style="margin-bottom:16px;">Penyebab Utama</h3>
        <div style="display:flex;flex-direction:column;gap:10px;">
            @foreach($causes as $c)
            @php $info = $causeLabels[$c] ?? [$svgAlert, $c, 'Faktor yang mempengaruhi skor']; @endphp
            <div class="hasil-cause-item" style="display:flex;align-items:center;gap:14px;padding:16px;border-radius:var(--radius-lg);">
                <div style="width:48px;height:48px;border-radius:12px;background:rgba(255,255,255,0.05);display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                    {!! $info[0] !!}
                </div>
                <div><div style="font-weight:700;color:#fff;">{{ $info[1] }}</div><div style="font-size:.8125rem;color:rgba(255,255,255,0.55);">{{ $info[2] }}</div></div>
            </div>
            @endforeach
        </div>
    </div>
    @endif

    {{-- Recommendations --}}
    @if(count($rekom))
    <div class="card hasil-card card-p anim-up d4" style="margin-bottom:24px;">
        <h3 style="margin-bottom:16px;">Rekomendasi</h3>
        <div style="display:flex;flex-direction:column;gap:12px;">
            @foreach($rekom as $i => $r)
            @php $text = is_string($r) ? $r : ($r['isi'] ?? $r['text'] ?? $r['rekomendasi'] ?? json_encode($r)); @endphp
            <div class="hasil-rec-item" style="display:flex;gap:14px;padding:16px;border-radius:var(--radius-lg);border-left:4px solid var(--teal);">
                <div style="width:28px;height:28px;border-radius:50%;background:rgba(0,229,200,.15);display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:.75rem;font-weight:800;color:var(--teal);">{{ $i+1 }}</div>
                <div style="font-size:.9375rem;line-height:1.7;color:rgba(255,255,255,0.85);">{{ $text }}</div>
            </div>
            @endforeach
        </div>
    </div>
    @endif
    @endif

    <div style="display:flex;gap:12px;justify-content:center;margin-top:20px;" class="anim-up d5">
        <a href="{{ url('/user/histori') }}" class="btn btn-primary">Lihat Histori</a>
        <a href="{{ url('/user/kuesioner') }}" class="btn btn-outline">Isi Lagi</a>
    </div>
</div>
@endsection
