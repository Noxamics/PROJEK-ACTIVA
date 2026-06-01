@extends('web.layouts.app')
@section('title', 'Grafik')

@section('styles')
@section('body-class', 'page-histori')
<link href="{{ asset('css/user-web/histori.css') }}" rel="stylesheet">
<link rel="stylesheet" href="{{ asset('css/user-web/grafik.css') }}">
@endsection

@section('content')
@php
    $isYear = $mode === 'year';

    if ($isYear && !empty($overrideLabels)) {
        $chartLabels = $overrideLabels;
        $chartScores = $overrideScores;
        $chartScreen = $overrideScreen;
        $chartSocial = $overrideSocial;
        $chartSleep  = $overrideSleep;
    } else {
        $chartLabels = $surveys->map(fn($s) => $s->created_at ? $s->created_at->format('d M') : '-')->toArray();
        $chartScores = $surveys->map(fn($s) => $s->score ?? 0)->toArray();
        $chartScreen = $surveys->map(fn($s) => $s->device_hours_per_day ?? 0)->toArray();
        $chartSocial = $surveys->map(fn($s) => $s->social_media_mins ?? 0)->toArray();
        $chartSleep  = $surveys->map(fn($s) => $s->sleep_quality ?? 0)->toArray();
    }

    // Stats always from raw surveys
    $scores    = $surveys->map(fn($s) => $s->score ?? 0)->toArray();
    $screen    = $surveys->map(fn($s) => $s->device_hours_per_day ?? 0)->toArray();
    $social    = $surveys->map(fn($s) => $s->social_media_mins ?? 0)->toArray();
    $low       = count(array_filter($scores, fn($s) => $s < 33.47));
    $med       = count(array_filter($scores, fn($s) => $s >= 33.47 && $s <= 61.34));
    $high      = count(array_filter($scores, fn($s) => $s > 61.34));
    $avgScore  = count($scores) > 0 ? round(array_sum($scores) / count($scores), 1) : 0;
    $avgScreen = count($screen) > 0 ? round(array_sum($screen) / count($screen), 1) : 0;
    $avgSocial = count($social) > 0 ? round(array_sum($social) / count($social)) : 0;
    $totalData = count($scores);
@endphp

{{-- Decorative background elements --}}
<div class="hist-bg"       aria-hidden="true"></div>
<div class="hist-orb-mid"  aria-hidden="true"></div>
<div class="hist-circle-1" aria-hidden="true"></div>
<div class="hist-circle-2" aria-hidden="true"></div>
<div class="hist-circle-3" aria-hidden="true"></div>
<div class="hist-circle-4" aria-hidden="true"></div>
<div class="hist-circle-5" aria-hidden="true"></div>
<div class="hist-circle-6" aria-hidden="true"></div>

{{-- Page Header --}}
<div class="page-header anim-fade">
    <h1>Grafik & Visualisasi</h1>
    <p>Lihat tren perkembangan gaya hidup digitalmu ✨</p>
</div>

{{-- Period Selector --}}
<div class="period-sel anim-up">
    <a href="{{ url('/user/grafik?mode=week') }}"
       class="period-btn {{ $mode=='week' ? 'active' : '' }}">7 Hari</a>
    <a href="{{ url('/user/grafik?mode=month&year='.$selectedYear.'&month='.$selectedMonth) }}"
       class="period-btn {{ $mode=='month' ? 'active' : '' }}">Bulanan</a>
    <a href="{{ url('/user/grafik?mode=year&year='.$selectedYear) }}"
       class="period-btn {{ $mode=='year' ? 'active' : '' }}">Tahunan</a>
</div>

{{-- Sub-filter: Bulanan → pilih bulan & tahun --}}
@if($mode === 'month')
<form method="GET" action="{{ url('/user/grafik') }}" class="period-subfilter anim-up">
    <input type="hidden" name="mode" value="month">
    <select name="year" class="filter-select" onchange="this.form.submit()">
        @foreach($availableYears as $yr)
        <option value="{{ $yr }}" {{ $selectedYear==$yr ? 'selected' : '' }}>{{ $yr }}</option>
        @endforeach
    </select>
    <select name="month" class="filter-select" onchange="this.form.submit()">
        @foreach($months as $num => $name)
        <option value="{{ $num }}" {{ $selectedMonth==$num ? 'selected' : '' }}>{{ $name }}</option>
        @endforeach
    </select>
</form>
@endif

{{-- Sub-filter: Tahunan → pilih tahun --}}
@if($mode === 'year')
<form method="GET" action="{{ url('/user/grafik') }}" class="period-subfilter anim-up">
    <input type="hidden" name="mode" value="year">
    <select name="year" class="filter-select" onchange="this.form.submit()">
        @foreach($availableYears as $yr)
        <option value="{{ $yr }}" {{ $selectedYear==$yr ? 'selected' : '' }}>{{ $yr }}</option>
        @endforeach
    </select>
</form>
@endif

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
                Bagus! Dependensi digitalmu terbilang rendah. Pertahankan keseimbanganmu! 
            @elseif($avgScore <= 61.34)
                Kamu ada di zona sedang. Yuk, mulai atur waktu layarmu lebih bijak! 
            @else
                Perhatikan gaya hidup digitalmu — tanda-tanda dependensi tinggi terdeteksi. 
            @endif
        </div>
    </div>
    <div style="text-align:right;flex-shrink:0;">
        <div style="font-size:1.5rem;font-weight:900;font-family:'Nunito',sans-serif;color:var(--purple);">{{ $avgScore }}</div>
        <div style="font-size:.6875rem;font-weight:600;color:var(--text-muted);letter-spacing:.06em;">AVG SKOR</div>
    </div>
</div>

@if($totalData < 3)
<div class="ai-insight-bar" style="background: rgba(139, 92, 246, 0.08); border-color: rgba(139, 92, 246, 0.2); margin-top: -12px; margin-bottom: 24px;">
    <div style="font-size: 1.5rem; flex-shrink: 0; animation: sparkle 2s infinite;">💡</div>
    <div class="ai-insight-text">
        <div class="label" style="color: var(--g-purple-light);">✦ Visualisasi Optimal Belum Terbuka</div>
        <div class="msg" style="font-size: 0.875rem; font-weight: 500;">
            Isi minimal <strong>3 kuesioner</strong> untuk menampilkan garis tren yang komprehensif. Progres Anda saat ini: <strong>{{ $totalData }}/3</strong>.
        </div>
    </div>
    <div style="flex-shrink:0; margin-left: 10px;">
        <a href="{{ url('/user/kuesioner') }}" class="period-btn active" style="font-size: 0.75rem; padding: 6px 14px; box-shadow: 0 4px 12px rgba(139, 92, 246, 0.25); background: linear-gradient(135deg, var(--purple), var(--g-purple)); border: none;">Isi Baru</a>
    </div>
</div>
@endif

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
const labels = {!! json_encode($chartLabels) !!};
const isSparse = {{ $isYear ? 'true' : 'false' }}; // year mode has nulls for empty months

/* ── Shared chart defaults ──────────────────────────────────── */
Chart.defaults.font.family = "'Plus Jakarta Sans', sans-serif";
Chart.defaults.color = 'rgba(255,255,255,0.7)';

const fontColor   = 'rgba(255,255,255,0.7)';
const gridColor   = 'rgba(255,255,255,0.1)';
const borderRad   = 8;

const baseScales = {
    x: {
        ticks: { color: fontColor, font: { size: 11, weight: '500' }, maxRotation: 0 },
        grid:  { display: false },
        border: { display: false },
        offset: true // Membersihkan ruang saat data sedikit
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
        backgroundColor: 'rgba(15,23,42,0.95)',
        titleColor: '#fff',
        bodyColor: 'rgba(255,255,255,0.8)',
        borderColor: 'rgba(255,255,255,0.1)',
        borderWidth: 1,
        cornerRadius: 10,
        padding: 10,
        titleFont: { weight: '700', size: 12 },
        bodyFont: { size: 12 }
    }
};

/* ── Line chart factory ─────────────────────────────────────── */
function mkLine(id, data, color, label, fillColor, yMin, yMax, ySuggestedMax) {
    const yConfig = { ...baseScales.y };
    if (yMin !== undefined) yConfig.min = yMin;
    if (yMax !== undefined) yConfig.max = yMax;
    if (ySuggestedMax !== undefined) yConfig.suggestedMax = ySuggestedMax;

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
                pointBackgroundColor: '#050D1A',
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
            scales: {
                x: baseScales.x,
                y: yConfig
            }
        }
    });
}

/* ── Bar chart factory ──────────────────────────────────────── */
function mkBar(id, data, color, label, yMin, yMax, ySuggestedMax) {
    const yConfig = { ...baseScales.y };
    if (yMin !== undefined) yConfig.min = yMin;
    if (yMax !== undefined) yConfig.max = yMax;
    if (ySuggestedMax !== undefined) yConfig.suggestedMax = ySuggestedMax;

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
            scales: {
                x: baseScales.x,
                y: yConfig
            }
        }
    });
}

@if(!$surveys->isEmpty() || $isYear)

/* Skor — teal gradient (0 s.d. 100) */
mkLine('chartScore', {!! json_encode($chartScores) !!}, '#00E5C8', 'Skor',
    'rgba(0,229,200,0.08)', 0, 100);

/* Screen time — blue (minimal 12 jam agar proporsional) */
mkLine('chartScreen', {!! json_encode($chartScreen) !!}, '#3B82F6', 'Jam',
    'rgba(59,130,246,0.08)', 0, undefined, 12);

/* Sosmed — purple bars (minimal 120 menit agar proporsional) */
mkBar('chartSocial', {!! json_encode($chartSocial) !!}, '#8B5CF6', 'Menit', 0, undefined, 120);

/* Sleep — amber bars (skala 1 s.d. 5) */
mkBar('chartSleep', {!! json_encode($chartSleep) !!}, '#F59E0B', 'Kualitas', 0, 5);

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
                    color: 'rgba(255,255,255,0.8)',
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