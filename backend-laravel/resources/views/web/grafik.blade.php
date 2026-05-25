@extends('web.layouts.app')
@section('title', 'Grafik')

@section('styles')
<link rel="stylesheet" href="{{ asset('css/user-web/grafik.css') }}">
@endsection

@section('content')
@php
    $labels = $surveys->map(fn($s) => $s->created_at ? $s->created_at->format('d M') : '-')->toArray();
    $scores = $surveys->map(fn($s) => $s->score ?? 0)->toArray();
    $screen = $surveys->map(fn($s) => $s->device_hours_per_day ?? 0)->toArray();
    $social = $surveys->map(fn($s) => $s->social_media_mins ?? 0)->toArray();
    $sleepQ = $surveys->map(fn($s) => $s->sleep_quality ?? 0)->toArray();
    $low  = count(array_filter($scores, fn($s) => $s < 33.47));
    $med  = count(array_filter($scores, fn($s) => $s >= 33.47 && $s <= 61.34));
    $high = count(array_filter($scores, fn($s) => $s > 61.34));

    $avgScore   = count($scores) > 0 ? round(array_sum($scores) / count($scores), 1) : 0;
    $avgScreen  = count($screen) > 0 ? round(array_sum($screen) / count($screen), 1) : 0;
    $avgSocial  = count($social) > 0 ? round(array_sum($social) / count($social)) : 0;
    $totalData  = count($scores);
@endphp

{{-- Decorative background elements --}}
<div class="grafik-orbs" aria-hidden="true"></div>
<div class="grafik-ring grafik-ring-1" aria-hidden="true"></div>
<div class="grafik-ring grafik-ring-2" aria-hidden="true"></div>
<div class="grafik-ring grafik-ring-3" aria-hidden="true"></div>

{{-- Page Header --}}
<div class="page-header anim-fade">
    <h1>Grafik & Visualisasi</h1>
    <p>Lihat tren perkembangan gaya hidup digitalmu ✨</p>
</div>

{{-- Period Selector --}}
<div class="period-sel anim-up">
    @foreach([7 => '7 Hari', 30 => 'Bulanan', 90 => '3 Bulan'] as $d => $label)
    <a href="{{ url('/user/grafik?days='.$d) }}" class="period-btn {{ $days==$d ? 'active' : '' }}">{{ $label }}</a>
    @endforeach
</div>

@if($surveys->isEmpty())

{{-- Empty state --}}
<div class="card card-p-lg anim-up" style="text-align:center;">
    @if(file_exists(public_path('images/maskot2.png')))
    <img src="{{ asset('images/maskot2.png') }}" alt="maskot" style="width:80px;margin-bottom:16px;filter:drop-shadow(0 4px 12px rgba(139,92,246,.3));animation:maskot-bounce 3s ease-in-out infinite;">
    @else
    <div style="font-size:3rem;margin-bottom:12px;">📊</div>
    @endif
    <h3>Belum Cukup Data</h3>
    <p style="color:var(--text-muted);margin-top:8px;">Isi kuesioner untuk melihat grafik perkembanganmu 🌱</p>
</div>

@else

{{-- Maskot AI Insight bar --}}
<div class="ai-insight-bar">
    @if(file_exists(public_path('images/maskot2.png')))
    <img src="{{ asset('images/maskot2.png') }}" alt="maskot" class="maskot">
    @endif
    <div class="ai-insight-text">
        <div class="label">✦ Insight Digital Wellness</div>
        <div class="msg">
            @if($avgScore < 33.47)
                Bagus! Dependensi digitalmu terbilang rendah. Pertahankan keseimbanganmu! 🌿
            @elseif($avgScore <= 61.34)
                Kamu ada di zona sedang. Yuk, mulai atur waktu layarmu lebih bijak! 💡
            @else
                Perhatikan gaya hidup digitalmu — tanda-tanda dependensi tinggi terdeteksi. 🔔
            @endif
        </div>
    </div>
    <div style="text-align:right;flex-shrink:0;">
        <div style="font-size:1.5rem;font-weight:900;font-family:'Nunito',sans-serif;color:var(--purple);">{{ $avgScore }}</div>
        <div style="font-size:.6875rem;font-weight:600;color:var(--text-muted);letter-spacing:.06em;">AVG SKOR</div>
    </div>
</div>

{{-- Stat chips --}}
<div class="stat-row">
    <div class="stat-chip sc-low" style="animation-delay:.05s">
        <div class="sc-val">{{ $low }}</div>
        <div class="sc-lbl">Rendah</div>
    </div>
    <div class="stat-chip sc-med" style="animation-delay:.10s">
        <div class="sc-val">{{ $med }}</div>
        <div class="sc-lbl">Sedang</div>
    </div>
    <div class="stat-chip sc-high" style="animation-delay:.15s">
        <div class="sc-val">{{ $high }}</div>
        <div class="sc-lbl">Tinggi</div>
    </div>
    <div class="stat-chip" style="animation-delay:.20s">
        <div class="sc-val" style="color:var(--blue);">{{ $avgScreen }}<span style="font-size:.75rem;font-weight:600">j</span></div>
        <div class="sc-lbl">Avg Screen</div>
    </div>
    <div class="stat-chip" style="animation-delay:.25s">
        <div class="sc-val" style="color:var(--purple);">{{ $avgSocial }}<span style="font-size:.75rem;font-weight:600">m</span></div>
        <div class="sc-lbl">Avg Sosmed</div>
    </div>
    <div class="stat-chip" style="animation-delay:.30s">
        <div class="sc-val" style="color:var(--teal);">{{ $totalData }}</div>
        <div class="sc-lbl">Total Data</div>
    </div>
</div>

{{-- Charts grid --}}
<div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;">

    {{-- Trend Skor (full width) --}}
    <div class="card card-p anim-up d1" style="grid-column:1/-1;">
        <h3 style="margin-bottom:4px;">Trend Skor Dependensi</h3>
        <p style="color:var(--text-muted);font-size:.8125rem;margin-bottom:16px;">Perubahan skor dari waktu ke waktu</p>
        <div class="chart-wrap"><canvas id="chartScore"></canvas></div>
    </div>

    {{-- Screen Time --}}
    <div class="card card-p anim-up d2">
        <h3 style="margin-bottom:4px;">Screen Time</h3>
        <p style="color:var(--text-muted);font-size:.8125rem;margin-bottom:16px;">Jam / hari</p>
        <div class="chart-wrap"><canvas id="chartScreen"></canvas></div>
    </div>

    {{-- Media Sosial --}}
    <div class="card card-p anim-up d3">
        <h3 style="margin-bottom:4px;">Media Sosial</h3>
        <p style="color:var(--text-muted);font-size:.8125rem;margin-bottom:16px;">Menit / hari</p>
        <div class="chart-wrap"><canvas id="chartSocial"></canvas></div>
    </div>

    {{-- Kualitas Tidur --}}
    <div class="card card-p anim-up d4">
        <h3 style="margin-bottom:4px;">Kualitas Tidur</h3>
        <p style="color:var(--text-muted);font-size:.8125rem;margin-bottom:16px;">Skala 1–5</p>
        <div class="chart-wrap"><canvas id="chartSleep"></canvas></div>
    </div>

    {{-- Distribusi --}}
    <div class="card card-p anim-up d5">
        <h3 style="margin-bottom:4px;">Distribusi Kategori</h3>
        <p style="color:var(--text-muted);font-size:.8125rem;margin-bottom:16px;">Persebaran tingkat</p>
        <div class="chart-wrap"><canvas id="chartDist"></canvas></div>
    </div>

</div>
@endif
@endsection

@section('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>
<script>
const labels = {!! json_encode($labels) !!};

/* ── Shared chart defaults ──────────────────────────────────── */
Chart.defaults.font.family = "'Plus Jakarta Sans', sans-serif";
Chart.defaults.color = '#64748B';

const fontColor   = '#64748B';
const gridColor   = 'rgba(226,232,240,0.6)';
const borderRad   = 8;

const baseScales = {
    x: {
        ticks: { color: fontColor, font: { size: 11, weight: '500' }, maxRotation: 0 },
        grid:  { display: false },
        border: { display: false }
    },
    y: {
        ticks: { color: fontColor, font: { size: 11, weight: '500' } },
        grid:  { color: gridColor, lineWidth: 1 },
        border: { display: false }
    }
};

const basePlugins = {
    legend: { display: false },
    tooltip: {
        backgroundColor: 'rgba(255,255,255,0.95)',
        titleColor: '#1E1B4B',
        bodyColor: '#475569',
        borderColor: 'rgba(139,92,246,0.2)',
        borderWidth: 1,
        cornerRadius: 10,
        padding: 10,
        titleFont: { weight: '700', size: 12 },
        bodyFont: { size: 12 }
    }
};

/* ── Line chart factory ─────────────────────────────────────── */
function mkLine(id, data, color, label, fillColor) {
    new Chart(document.getElementById(id), {
        type: 'line',
        data: {
            labels,
            datasets: [{
                label,
                data,
                borderColor: color,
                backgroundColor: fillColor || color + '15',
                fill: true,
                tension: 0.45,
                pointRadius: 4,
                pointHoverRadius: 7,
                pointBackgroundColor: '#fff',
                pointBorderColor: color,
                pointBorderWidth: 2.5,
                borderWidth: 2.5
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: { intersect: false, mode: 'index' },
            plugins: basePlugins,
            scales: baseScales
        }
    });
}

/* ── Bar chart factory ──────────────────────────────────────── */
function mkBar(id, data, color, label) {
    new Chart(document.getElementById(id), {
        type: 'bar',
        data: {
            labels,
            datasets: [{
                label,
                data,
                backgroundColor: color + '30',
                hoverBackgroundColor: color + '60',
                borderColor: color,
                borderWidth: 2,
                borderRadius: borderRad,
                borderSkipped: false
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: { intersect: false, mode: 'index' },
            plugins: basePlugins,
            scales: baseScales
        }
    });
}

@if(!$surveys->isEmpty())

/* Skor — teal gradient */
mkLine('chartScore', {!! json_encode($scores) !!}, '#0D9488', 'Skor',
    'rgba(13,148,136,0.08)');

/* Screen time — blue */
mkLine('chartScreen', {!! json_encode($screen) !!}, '#3B82F6', 'Jam',
    'rgba(59,130,246,0.08)');

/* Sosmed — purple bars */
mkBar('chartSocial', {!! json_encode($social) !!}, '#8B5CF6', 'Menit');

/* Sleep — amber bars */
mkBar('chartSleep', {!! json_encode($sleepQ) !!}, '#F59E0B', 'Kualitas');

/* Distribusi — doughnut */
new Chart(document.getElementById('chartDist'), {
    type: 'doughnut',
    data: {
        labels: ['Rendah', 'Sedang', 'Tinggi'],
        datasets: [{
            data: [{{ $low }}, {{ $med }}, {{ $high }}],
            backgroundColor: ['#22C55E', '#F59E0B', '#EF4444'],
            hoverBackgroundColor: ['#16A34A', '#D97706', '#DC2626'],
            borderWidth: 0,
            hoverOffset: 8
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                position: 'bottom',
                labels: {
                    color: '#475569',
                    font: { size: 12, weight: '600' },
                    padding: 16,
                    usePointStyle: true,
                    pointStyleWidth: 10
                }
            },
            tooltip: basePlugins.tooltip
        },
        cutout: '68%'
    }
});
@endif
</script>
@endsection