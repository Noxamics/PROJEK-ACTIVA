@extends('web.layouts.app')
@section('title', 'Laporan')

@section('content')
<div style="max-width:800px;margin:0 auto;">
    <div class="page-header anim-fade"><h1>Laporan Perkembangan</h1><p>Perbandingan minggu ini vs minggu lalu</p></div>

    @if($locked)
    <div class="card card-p-lg anim-up" style="text-align:center;">
        <div style="font-size:3rem;margin-bottom:12px;">🔒</div>
        <h2>Belum Cukup Data</h2>
        <p style="color:var(--text-muted);margin:8px 0;">Butuh minimal <strong>14 data kuesioner</strong></p>
        <div class="progress-bar" style="max-width:300px;margin:16px auto;"><div class="progress-fill" style="width:{{ min(100, ($totalCount/14)*100) }}%"></div></div>
        <p style="color:var(--text-muted);font-size:.8125rem;">{{ $totalCount }} / 14 kuesioner terisi</p>
        <a href="{{ url('/user/kuesioner') }}" class="btn btn-primary" style="margin-top:20px;">Isi Kuesioner</a>
    </div>
    @else
    @php
        $statusIcon = $status === 'membaik' ? '📈' : ($status === 'memburuk' ? '📉' : '📊');
        $insightConfig = [
            ['dependensi', '🧠', 'Dependensi Digital', 'skor', false],
            ['screen_time', '📱', 'Screen Time', 'jam', false],
            ['social_media', '💬', 'Media Sosial', 'menit', false],
            ['tidur', '😴', 'Tidur', 'jam', true],
            ['stres', '🤯', 'Stres', 'level', false],
        ];
        $causeNames = ['screen_time_high'=>'Screen Time Tinggi','notification_overload'=>'Notifikasi Berlebihan','sleep_low'=>'Kurang Tidur','sleep_bad_quality'=>'Kualitas Tidur Buruk','anxiety_high'=>'Kecemasan Tinggi','depression_high'=>'Depresi Tinggi','stress_high'=>'Stres Tinggi','happiness_low'=>'Kebahagiaan Rendah'];
    @endphp

    <div class="card card-p-lg anim-up" style="text-align:center;margin-bottom:24px;background:var(--bg-dark);border:1px solid var(--border-card);">
        <div style="font-size:2rem;">{{ $statusIcon }}</div>
        <h2 style="color:var(--text-primary);margin-top:8px;">Status: {{ ucfirst($status) }}</h2>
        <p style="color:var(--text-secondary);margin-top:4px;">Berdasarkan perbandingan 7 data terbaru vs 7 sebelumnya</p>
    </div>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:24px;">
        @foreach($insightConfig as $ic)
        @php
            $d = $insights[$ic[0]] ?? null;
            $isInverse = $ic[4];
            $chg = $d['change'] ?? 0;
            $isGood = $isInverse ? $chg >= 0 : $chg <= 0;
        @endphp
        <div class="card card-p anim-up d2">
            <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                <span style="font-size:1.5rem;">{{ $ic[1] }}</span>
                @if($d)<span class="badge badge-{{ $isGood ? 'green' : 'red' }}">{{ $chg <= 0 ? '↓' : '↑' }} {{ abs($chg) }}%</span>@endif
            </div>
            <h4 style="margin-top:8px;">{{ $ic[2] }}</h4>
            @if($d)
            <div style="font-size:1.5rem;font-weight:900;margin-top:4px;">{{ $d['current'] }} <span style="font-size:.75rem;color:var(--text-muted);font-weight:500;">{{ $ic[3] }}</span></div>
            <p style="font-size:.8125rem;color:var(--text-muted);margin-top:2px;">Sebelumnya: {{ $d['previous'] }}</p>
            @else
            <p style="color:var(--text-muted);font-size:.8125rem;">Data belum tersedia</p>
            @endif
        </div>
        @endforeach
    </div>

    @if(!empty($topCauses))
    <div class="card card-p anim-up d3" style="margin-bottom:24px;">
        <h3 style="margin-bottom:16px;">3 Penyebab Teratas</h3>
        <div style="display:flex;flex-direction:column;gap:10px;">
            @php $rank = 1; @endphp
            @foreach($topCauses as $cause => $count)
            <div style="display:flex;align-items:center;gap:14px;padding:14px;background:var(--bg-light);border-radius:var(--radius-lg);">
                <div style="width:32px;height:32px;border-radius:50%;background:rgba(13,148,136,.08);display:flex;align-items:center;justify-content:center;font-weight:800;color:var(--teal);font-size:.875rem;">{{ $rank++ }}</div>
                <div style="flex:1;"><div style="font-weight:700;font-size:.9375rem;">{{ $causeNames[$cause] ?? $cause }}</div><div style="font-size:.8125rem;color:var(--text-muted);">Muncul {{ $count }}x dari 14 data</div></div>
            </div>
            @endforeach
        </div>
    </div>
    @endif
    @endif
</div>
@endsection
