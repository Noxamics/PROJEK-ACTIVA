@extends('web.layouts.app')
@section('title', 'Laporan')

@section('styles')
@section('body-class', 'page-histori')
<link href="{{ asset('css/user-web/histori.css') }}" rel="stylesheet">
<style>
    .laporan-card {
        background: rgba(255,255,255,0.06) !important;
        border: 1px solid rgba(255,255,255,0.1) !important;
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        color: #fff !important;
        transition: transform 0.25s cubic-bezier(0.4,0,0.2,1), box-shadow 0.25s, border-color 0.25s !important;
    }
    .laporan-card:hover {
        transform: translateY(-4px);
        border-color: rgba(0,229,200,0.4) !important;
        box-shadow: 0 12px 40px rgba(0,229,200,0.15), 0 4px 12px rgba(0,0,0,0.3) !important;
    }
    .laporan-card h2, .laporan-card h3, .laporan-card h4 { color: #fff !important; }
    .laporan-card p, .laporan-card div { color: rgba(255,255,255,0.85); }
    .laporan-cause-item {
        background: rgba(255,255,255,0.04) !important;
        border: 1px solid rgba(255,255,255,0.08);
        transition: transform 0.2s;
    }
    .laporan-cause-item:hover {
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

<div style="max-width:800px;margin:0 auto;position:relative;z-index:2;">
    <div class="hist-header anim-fade"><h1>Laporan Perkembangan</h1><p>Perbandingan minggu ini vs minggu lalu</p></div>

    @if($locked)
    <div class="card laporan-card card-p-lg anim-up" style="text-align:center;">
        <div style="font-size:3rem;margin-bottom:12px;">🔒</div>
        <h2>Belum Cukup Data</h2>
        <p style="color:rgba(255,255,255,0.55);margin:8px 0;">Butuh minimal <strong style="color:#fff;">14 data kuesioner</strong></p>
        <div class="progress-bar" style="max-width:300px;margin:16px auto;background:rgba(255,255,255,0.1);"><div class="progress-fill" style="width:{{ min(100, ($totalCount/14)*100) }}%;background:var(--teal);"></div></div>
        <p style="color:rgba(255,255,255,0.55);font-size:.8125rem;">{{ $totalCount }} / 14 kuesioner terisi</p>
        <a href="{{ url('/user/kuesioner') }}" class="btn btn-primary" style="margin-top:20px;">Isi Kuesioner</a>
    </div>
    @else
    @php
        $svgUp = '<svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#22c55e" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"></polyline><polyline points="16 7 22 7 22 13"></polyline></svg>';
        $svgDown = '<svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 17 13.5 8.5 8.5 13.5 2 7"></polyline><polyline points="16 17 22 17 22 11"></polyline></svg>';
        $svgNeutral = '<svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>';
        $statusIcon = $status === 'membaik' ? $svgUp : ($status === 'memburuk' ? $svgDown : $svgNeutral);
        
        $svgBrain = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#a855f7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96.44 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 1.98-3A2.5 2.5 0 0 1 9.5 2Z"/><path d="M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96.44 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-1.98-3A2.5 2.5 0 0 0 14.5 2Z"/></svg>';
        $svgPhone = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#0ea5e9" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="2" ry="2"></rect><line x1="12" y1="18" x2="12.01" y2="18"></line></svg>';
        $svgMessage = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#f59e0b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>';
        $svgMoon = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>';
        $svgZap = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg>';

        $insightConfig = [
            ['dependensi', $svgBrain, 'Dependensi Digital', 'skor', false],
            ['screen_time', $svgPhone, 'Screen Time', 'jam', false],
            ['social_media', $svgMessage, 'Media Sosial', 'menit', false],
            ['tidur', $svgMoon, 'Tidur', 'jam', true],
            ['stres', $svgZap, 'Stres', 'level', false],
        ];
        $causeNames = ['screen_time_high'=>'Screen Time Tinggi','notification_overload'=>'Notifikasi Berlebihan','sleep_low'=>'Kurang Tidur','sleep_bad_quality'=>'Kualitas Tidur Buruk','anxiety_high'=>'Kecemasan Tinggi','depression_high'=>'Depresi Tinggi','stress_high'=>'Stres Tinggi','happiness_low'=>'Kebahagiaan Rendah'];
    @endphp

    <div class="card laporan-card card-p-lg anim-up" style="text-align:center;margin-bottom:24px;">
        <div style="display:flex;justify-content:center;margin-bottom:8px;">{!! $statusIcon !!}</div>
        <h2 style="color:#fff;margin-top:8px;">Status: {{ ucfirst($status) }}</h2>
        <p style="color:rgba(255,255,255,0.7);margin-top:4px;">Berdasarkan perbandingan 7 data terbaru vs 7 sebelumnya</p>
    </div>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:24px;">
        @foreach($insightConfig as $ic)
        @php
            $d = $insights[$ic[0]] ?? null;
            $isInverse = $ic[4];
            $chg = $d['change'] ?? 0;
            $isGood = $isInverse ? $chg >= 0 : $chg <= 0;
        @endphp
        <div class="card laporan-card card-p anim-up d2">
            <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                <span style="display:flex;align-items:center;justify-content:center;width:40px;height:40px;border-radius:10px;background:rgba(255,255,255,0.06);">{!! $ic[1] !!}</span>
                @if($d)<span class="badge badge-{{ $isGood ? 'green' : 'red' }}">{{ $chg <= 0 ? '↓' : '↑' }} {{ abs($chg) }}%</span>@endif
            </div>
            <h4 style="margin-top:12px;color:#fff;">{{ $ic[2] }}</h4>
            @if($d)
            <div style="font-size:1.5rem;font-weight:900;margin-top:4px;color:#fff;">{{ $d['current'] }} <span style="font-size:.75rem;color:rgba(255,255,255,0.55);font-weight:500;">{{ $ic[3] }}</span></div>
            <p style="font-size:.8125rem;color:rgba(255,255,255,0.55);margin-top:2px;">Sebelumnya: {{ $d['previous'] }}</p>
            @else
            <p style="color:rgba(255,255,255,0.55);font-size:.8125rem;margin-top:8px;">Data belum tersedia</p>
            @endif
        </div>
        @endforeach
    </div>

    @if(!empty($topCauses))
    <div class="card laporan-card card-p anim-up d3" style="margin-bottom:24px;">
        <h3 style="margin-bottom:16px;color:#fff;">3 Penyebab Teratas</h3>
        <div style="display:flex;flex-direction:column;gap:10px;">
            @php $rank = 1; @endphp
            @foreach($topCauses as $cause => $count)
            <div class="laporan-cause-item" style="display:flex;align-items:center;gap:14px;padding:14px;border-radius:var(--radius-lg);">
                <div style="width:32px;height:32px;border-radius:50%;background:rgba(0,229,200,.15);display:flex;align-items:center;justify-content:center;font-weight:800;color:var(--teal);font-size:.875rem;">{{ $rank++ }}</div>
                <div style="flex:1;"><div style="font-weight:700;font-size:.9375rem;color:#fff;">{{ $causeNames[$cause] ?? $cause }}</div><div style="font-size:.8125rem;color:rgba(255,255,255,0.55);">Muncul {{ $count }}x dari 14 data</div></div>
            </div>
            @endforeach
        </div>
    </div>
    @endif
    @endif
</div>
@endsection
