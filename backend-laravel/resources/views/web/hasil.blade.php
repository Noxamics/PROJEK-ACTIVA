@extends('web.layouts.app')
@section('title', 'Hasil Analisis')

@section('content')
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
    $causeLabels = [
        'screen_time_high' => ['📱','Screen Time Berlebihan','Penggunaan perangkat terlalu lama setiap hari'],
        'notification_overload' => ['🔔','Notifikasi Berlebihan','Terlalu banyak notifikasi mengganggu fokus'],
        'sleep_low' => ['😴','Kurang Tidur','Durasi tidur di bawah 7 jam yang ideal'],
        'sleep_bad_quality' => ['🛌','Kualitas Tidur Buruk','Kualitas tidur tidak optimal'],
        'anxiety_high' => ['😰','Kecemasan Tinggi','Tingkat kecemasan di atas normal'],
        'depression_high' => ['😔','Depresi Tinggi','Skor depresi mengkhawatirkan'],
        'stress_high' => ['🤯','Stres Tinggi','Tingkat stres perlu diwaspadai'],
        'happiness_low' => ['😞','Kebahagiaan Rendah','Tingkat kebahagiaan di bawah rata-rata'],
        'tidur_kurang' => ['😴','Kurang Tidur','Durasi tidur kurang dari ideal'],
        'screen_time_tinggi' => ['📱','Screen Time Tinggi','Penggunaan layar berlebihan'],
        'social_media_tinggi' => ['💬','Media Sosial Berlebihan','Penggunaan media sosial terlalu lama'],
    ];
@endphp

<div style="max-width:800px;margin:0 auto;">
    <div class="page-header anim-fade"><h1>Hasil Analisis</h1><p>{{ $q->created_at ? $q->created_at->format('d M Y, H:i') : '' }}</p></div>

    @if(!$ml)
    <div class="card card-p-lg anim-up" style="text-align:center;">
        <div style="font-size:3rem;margin-bottom:12px;">⏳</div>
        <h2>Prediksi Belum Tersedia</h2>
        <p style="color:var(--text-muted);margin:12px 0;">ML service mungkin sedang tidak aktif. Silakan coba lagi nanti.</p>
        <a href="{{ url('/user/dashboard') }}" class="btn btn-primary">Kembali ke Dashboard</a>
    </div>
    @else
    {{-- Score --}}
    <div class="card card-p-lg anim-up" style="text-align:center;margin-bottom:24px;">
        <div class="score-gauge" style="width:200px;height:200px;">
            <svg viewBox="0 0 200 200">
                <circle cx="100" cy="100" r="85" fill="none" stroke="{{ $scoreColor }}15" stroke-width="12"/>
                <circle cx="100" cy="100" r="85" fill="none" stroke="{{ $scoreColor }}" stroke-width="12" stroke-linecap="round"
                    stroke-dasharray="{{ $circ }}" stroke-dashoffset="{{ $offset }}" style="transition:stroke-dashoffset 1.5s cubic-bezier(.16,1,.3,1)"/>
            </svg>
            <div class="score-gauge-text">
                <div class="score-value" style="color:{{ $scoreColor }};">{{ round($score) }}</div>
                <div class="score-label">dari 100</div>
            </div>
        </div>
        <span class="badge badge-{{ $scoreBadge }}" style="font-size:.875rem;padding:8px 20px;margin-top:16px;">Tingkat {{ $scoreCat }}</span>
    </div>

    {{-- AI Analysis --}}
    @if(!empty($summary))
    <div class="card card-p anim-up d2" style="margin-bottom:24px;">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px;">
            <div style="width:40px;height:40px;border-radius:var(--radius-lg);background:rgba(139,92,246,.06);display:flex;align-items:center;justify-content:center;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--purple)" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M12 1v2m0 18v2M4.22 4.22l1.42 1.42m12.72 12.72l1.42 1.42M1 12h2m18 0h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>
            </div>
            <h3>Analisis AI</h3>
        </div>
        <p style="color:var(--text-muted);font-size:.9375rem;line-height:1.8;">{{ $summary }}</p>
    </div>
    @endif

    {{-- Causes --}}
    @if(count($causes))
    <div class="card card-p anim-up d3" style="margin-bottom:24px;">
        <h3 style="margin-bottom:16px;">Penyebab Utama</h3>
        <div style="display:flex;flex-direction:column;gap:10px;">
            @foreach($causes as $c)
            @php $info = $causeLabels[$c] ?? ['⚠️', $c, 'Faktor yang mempengaruhi skor']; @endphp
            <div style="display:flex;align-items:center;gap:14px;padding:16px;background:var(--bg-light);border-radius:var(--radius-lg);">
                <span style="font-size:1.75rem;">{{ $info[0] }}</span>
                <div><div style="font-weight:700;">{{ $info[1] }}</div><div style="font-size:.8125rem;color:var(--text-muted);">{{ $info[2] }}</div></div>
            </div>
            @endforeach
        </div>
    </div>
    @endif

    {{-- Recommendations --}}
    @if(count($rekom))
    <div class="card card-p anim-up d4" style="margin-bottom:24px;">
        <h3 style="margin-bottom:16px;">Rekomendasi</h3>
        <div style="display:flex;flex-direction:column;gap:12px;">
            @foreach($rekom as $i => $r)
            @php $text = is_string($r) ? $r : ($r['isi'] ?? $r['text'] ?? $r['rekomendasi'] ?? json_encode($r)); @endphp
            <div style="display:flex;gap:14px;padding:16px;background:var(--bg-light);border-radius:var(--radius-lg);border-left:4px solid var(--teal);">
                <div style="width:28px;height:28px;border-radius:50%;background:rgba(13,148,136,.08);display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:.75rem;font-weight:800;color:var(--teal);">{{ $i+1 }}</div>
                <div style="font-size:.9375rem;line-height:1.7;">{{ $text }}</div>
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
