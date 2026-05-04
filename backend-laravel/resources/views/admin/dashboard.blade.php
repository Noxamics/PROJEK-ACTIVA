{{--
═══════════════════════════════════════════════
resources/views/admin/dashboard.blade.php
═══════════════════════════════════════════════
--}}
@extends('layouts.app')
@section('title', 'Dashboard — Activa')
@section('page-title', 'Dashboard')

@push('head-scripts')
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
@endpush

@section('content')

    {{-- Data Bridge --}}
    <div id="chart-data"
        data-risk-dist='@json($riskDist ?? [])'
        data-score-trend='@json($scoreTrend ?? ["daily" => [], "weekly" => [], "monthly" => []])'
        data-grouped-bar='@json($groupedBar ?? [])'
        data-daily-submissions='@json($dailySubmissions ?? ["labels" => [], "data" => []])'
        data-score-histogram='@json($scoreHistogram ?? ["labels" => [], "data" => []])'
        hidden>
    </div>

    {{-- ══════════════════════════════════════════════════════════
         ROW 1 — Chart 1: Score Trend (Line)  |  Chart 2: Donut
    ══════════════════════════════════════════════════════════ --}}
    <div class="grid-2-1 mb-charts">

        {{-- 1. Rata-rata Skor Ketergantungan Digital --}}
        <div class="card">
            <div class="card-header">
                <div>
                    <div class="card-title">Rata-rata Skor Ketergantungan Digital</div>
                    <div class="card-sub">Tren perubahan skor dari waktu ke waktu</div>
                </div>
                <div class="tab-group" id="scoreTrendTabs">
                    <button class="tab-btn active" data-period="daily">Harian</button>
                    <button class="tab-btn" data-period="weekly">Mingguan</button>
                    <button class="tab-btn" data-period="monthly">Bulanan</button>
                </div>
            </div>
            <div class="chart-canvas-wrap">
                <canvas id="scoreTrendChart"></canvas>
            </div>
        </div>

        {{-- 2. Distribusi Risk Level --}}
        <div class="card">
            <div class="card-header">
                <div>
                    <div class="card-title">Distribusi Risk Level</div>
                    <div class="card-sub">Berdasarkan digital dependence</div>
                </div>
            </div>
            <div class="donut-canvas-wrap">
                <canvas id="donutChart"></canvas>
            </div>
            <div class="risk-legend">
                @foreach($riskDist ?? [] as $item)
                    <div class="risk-legend-row">
                        <span class="risk-legend-label">
                            <span class="risk-legend-dot dot-{{ $item['color'] }}"></span>
                            {{ $item['label'] }}
                        </span>
                        <span class="risk-legend-value value-{{ $item['color'] }}">
                            {{ $item['pct'] }}% · {{ $item['count'] }} user
                        </span>
                    </div>
                @endforeach
            </div>
        </div>

    </div>

    {{-- ══════════════════════════════════════════════════════════
         ROW 2 — Chart 3: Kategori (Line)  |  Chart 4: Submissions (Line)
    ══════════════════════════════════════════════════════════ --}}
    <div class="grid-2 mb-charts">

        {{-- 3. Perbandingan Berdasarkan Kategori --}}
        <div class="card">
            <div class="card-header">
                <div>
                    <div class="card-title">Perbandingan Berdasarkan Kategori</div>
                    <div class="card-sub">Distribusi risk level per kelompok</div>
                </div>
                <div class="chart-dropdown-wrap">
                    <select class="chart-dropdown" id="groupedBarSelect">
                        <option value="byRole">Peran (Role)</option>
                        <option value="byGender">Gender</option>
                        <option value="byAge">Kelompok Usia</option>
                        <option value="byRegion">Region</option>
                    </select>
                    <svg class="chart-dropdown-arrow" xmlns="http://www.w3.org/2000/svg" width="14" height="14"
                        viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"
                        stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="6 9 12 15 18 9"/>
                    </svg>
                </div>
            </div>
            <div class="chart-canvas-wrap">
                <canvas id="groupedBarChart"></canvas>
            </div>
        </div>

        {{-- 4. Kuesioner Terisi per Hari --}}
        <div class="card">
            <div class="card-header">
                <div>
                    <div class="card-title">Kuesioner Terisi per Hari</div>
                    <div class="card-sub">Pantau pertumbuhan pengguna aktif</div>
                </div>
            </div>
            <div class="chart-canvas-wrap">
                <canvas id="submissionsChart"></canvas>
            </div>
        </div>

    </div>

    {{-- ══════════════════════════════════════════════════════════
         ROW 3 — Chart 5: Distribusi Skor (Line, full width)
    ══════════════════════════════════════════════════════════ --}}
    <div class="mb-charts">
        <div class="card">
            <div class="card-header">
                <div>
                    <div class="card-title">Distribusi Skor</div>
                    <div class="card-sub">Sebaran skor ketergantungan seluruh user</div>
                </div>
            </div>
            <div class="chart-canvas-wrap">
                <canvas id="histogramChart"></canvas>
            </div>
        </div>
    </div>

    {{-- ══════════════════════════════════════════════════════════
         ROW 4 — Card 6: Summary Insight  |  Card 7: Threshold
    ══════════════════════════════════════════════════════════ --}}
    <div class="grid-2 mb-charts">

        {{-- 6. Summary Insight --}}
        <div class="card">
            <div class="card-header">
                <div>
                    <div class="card-title">Summary Insight</div>
                    <div class="card-sub">Ringkasan otomatis dari data</div>
                </div>
            </div>
            <div class="insight-list">
                @forelse($summaryInsights ?? [] as $insight)
                    <div class="insight-item insight-item--{{ $insight['type'] ?? 'info' }}">
                        <span class="insight-icon">
                            @if(($insight['type'] ?? '') === 'info')
                                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#0D9488" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                            @elseif(($insight['type'] ?? '') === 'up')
                                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1E3A5F" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
                            @elseif(($insight['type'] ?? '') === 'warning')
                                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#D97706" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                            @elseif(($insight['type'] ?? '') === 'danger')
                                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E05252" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                            @else
                                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#4A6180" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                            @endif
                        </span>
                        <span class="insight-text">{{ $insight['text'] }}</span>
                    </div>
                @empty
                    <div class="insight-item insight-item--info">
                        <span class="insight-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#0D9488" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        </span>
                        <span class="insight-text">Mayoritas user berada di kategori Sedang (52%)</span>
                    </div>
                    <div class="insight-item insight-item--up">
                        <span class="insight-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1E3A5F" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
                        </span>
                        <span class="insight-text">Rata-rata skor meningkat +5 poin minggu ini</span>
                    </div>
                    <div class="insight-item insight-item--warning">
                        <span class="insight-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#D97706" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                        </span>
                        <span class="insight-text">Penggunaan device &gt; 6 jam/hari berkorelasi dengan skor tinggi</span>
                    </div>
                    <div class="insight-item insight-item--danger">
                        <span class="insight-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E05252" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        </span>
                        <span class="insight-text">12 user masuk kategori High Risk, perlu perhatian segera</span>
                    </div>
                @endforelse
            </div>
        </div>

        {{-- 7. Threshold Kategori Skor --}}
        <div class="card">
            <div class="card-header">
                <div>
                    <div class="card-title">Threshold Kategori Skor</div>
                    <div class="card-sub">Acuan pengelompokan tingkat ketergantungan</div>
                </div>
            </div>

            @php
                $thresholds = $thresholds ?? [
                    ['label' => 'Rendah', 'range' => '0 – 39',   'color' => 'teal',  'desc' => 'Ketergantungan digital masih dalam batas normal'],
                    ['label' => 'Sedang', 'range' => '40 – 69',  'color' => 'amber', 'desc' => 'Mulai menunjukkan pola penggunaan yang berlebihan'],
                    ['label' => 'Tinggi', 'range' => '70 – 100', 'color' => 'red',   'desc' => 'Ketergantungan digital sudah pada level mengkhawatirkan'],
                ];
            @endphp

            <div class="threshold-cards">
                @foreach($thresholds as $t)
                    <div class="threshold-card threshold-card--{{ $t['color'] }}">
                        <div class="threshold-card-top">
                            <span class="threshold-card-label">{{ $t['label'] }}</span>
                            <span class="threshold-card-range">{{ $t['range'] }}</span>
                        </div>
                        @if(isset($t['desc']))
                            <div class="threshold-card-desc">{{ $t['desc'] }}</div>
                        @endif
                    </div>
                @endforeach
            </div>
        </div>

    </div>

@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function () {

    const C = {
        navy   : '#1E3A5F',
        navyLt : '#264875',
        teal   : '#0D9488',
        amber  : '#D97706',
        red    : '#E05252',
        text   : '#4A6180',
        grid   : 'rgba(30,58,95,0.06)',
        white  : '#ffffff',
    };

    const TOOLTIP = {
        backgroundColor : C.white,
        borderColor     : '#E4EEF6',
        borderWidth     : 1,
        titleColor      : C.navy,
        bodyColor       : C.text,
        padding         : 10,
        cornerRadius    : 8,
    };

    const AXIS = (opts = {}) => ({
        grid  : { color: C.grid },
        ticks : { color: C.text, font: { family: 'DM Sans', size: 11 } },
        ...opts,
    });

    function safeJson(str, fallback) {
        try { return JSON.parse(str || 'null') || fallback; }
        catch (e) { return fallback; }
    }

    function lineDataset(label, data, color, fill = true) {
        return {
            label,
            data,
            borderColor          : color,
            backgroundColor      : fill ? color + '18' : 'transparent',
            fill,
            tension              : 0.4,
            pointRadius          : 5,
            pointBackgroundColor : color,
            pointBorderColor     : C.white,
            pointBorderWidth     : 2,
            borderWidth          : 2.5,
        };
    }

    /* ── Read data bridge ── */
    const el = document.getElementById('chart-data');
    const _riskDist         = el ? safeJson(el.dataset.riskDist,         [])                       : [];
    const _scoreTrend       = el ? safeJson(el.dataset.scoreTrend,       {})                       : {};
    const _groupedBar       = el ? safeJson(el.dataset.groupedBar,       {})                       : {};
    const _dailySubmissions = el ? safeJson(el.dataset.dailySubmissions, { labels:[], data:[] })   : { labels:[], data:[] };
    const _scoreHistogram   = el ? safeJson(el.dataset.scoreHistogram,   { labels:[], data:[] })   : { labels:[], data:[] };

    /* ── Dummy data ── */
    const DUMMY = {
        riskDist : [
            { label:'Rendah', pct:35, count:45, color:'teal'  },
            { label:'Sedang', pct:52, count:66, color:'amber' },
            { label:'Tinggi', pct:13, count:17, color:'red'   },
        ],
        scoreTrend : {
            daily   : { labels:['Sen','Sel','Rab','Kam','Jum','Sab','Min'], data:[52,58,55,63,60,67,64] },
            weekly  : { labels:['Mg 1','Mg 2','Mg 3','Mg 4'],              data:[54,57,61,65] },
            monthly : { labels:['Jan','Feb','Mar','Apr','Mei','Jun'],       data:[48,52,55,59,62,65] },
        },
        groupedBar : {
            byRole   : { labels:['Mahasiswa','Pekerja','Lainnya'],                     rendah:[30,42,28], sedang:[50,43,52], tinggi:[20,15,20] },
            byGender : { labels:['Laki-laki','Perempuan'],                             rendah:[30,40],    sedang:[50,54],    tinggi:[20,6]    },
            byAge    : { labels:['< 18','18–24','25–34','35–44','45+'],                rendah:[20,28,38,45,50], sedang:[55,52,48,42,38], tinggi:[25,20,14,13,12] },
            byRegion : { labels:['Jawa','Sumatera','Kalimantan','Sulawesi','Lainnya'], rendah:[33,36,40,38,42], sedang:[52,50,48,50,46], tinggi:[15,14,12,12,12] },
        },
        dailySubmissions : {
            labels : ['19 Apr','20 Apr','21 Apr','22 Apr','23 Apr','24 Apr','25 Apr'],
            data   : [8,14,9,18,22,20,27],
        },
        scoreHistogram : {
            labels : ['0–9','10–19','20–29','30–39','40–49','50–59','60–69','70–79','80–89','90–100'],
            data   : [2,4,8,14,22,30,24,16,10,6],
        },
    };

    const riskDist         = _riskDist.length              > 0 ? _riskDist         : DUMMY.riskDist;
    const scoreTrend       = Object.keys(_scoreTrend).length   > 0 ? _scoreTrend   : DUMMY.scoreTrend;
    const groupedBar       = Object.keys(_groupedBar).length   > 0 ? _groupedBar   : DUMMY.groupedBar;
    const dailySubmissions = _dailySubmissions.labels?.length  > 0 ? _dailySubmissions : DUMMY.dailySubmissions;
    const scoreHistogram   = _scoreHistogram.labels?.length    > 0 ? _scoreHistogram   : DUMMY.scoreHistogram;

    /* ══════════════════════════════════════════════
       1. SCORE TREND — Line Chart
    ══════════════════════════════════════════════ */
    const trendEl = document.getElementById('scoreTrendChart');
    let scoreTrendChart = null;

    function buildTrendData(period) {
        const src = scoreTrend[period] || scoreTrend['daily'];
        return {
            labels   : src.labels,
            datasets : [lineDataset('Avg. Skor', src.data, C.navy)],
        };
    }

    function renderScoreTrend(period) {
        if (!trendEl) return;
        if (scoreTrendChart) {
            scoreTrendChart.data = buildTrendData(period);
            scoreTrendChart.update('active');
        } else {
            scoreTrendChart = new Chart(trendEl, {
                type    : 'line',
                data    : buildTrendData(period),
                options : {
                    responsive          : true,
                    maintainAspectRatio : false,
                    interaction         : { mode: 'index', intersect: false },
                    plugins : {
                        legend  : { display: false },
                        tooltip : { ...TOOLTIP, callbacks: { label: ctx => ` Skor: ${ctx.parsed.y}` } },
                    },
                    scales : {
                        x : AXIS(),
                        y : AXIS({ min:0, max:100, ticks: { ...AXIS().ticks, callback: v => v } }),
                    },
                },
            });
        }
    }

    renderScoreTrend('daily');

    document.getElementById('scoreTrendTabs')?.addEventListener('click', e => {
        const btn = e.target.closest('.tab-btn');
        if (!btn) return;
        document.querySelectorAll('#scoreTrendTabs .tab-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        renderScoreTrend(btn.dataset.period);
    });

    /* ══════════════════════════════════════════════
       2. DONUT — Distribusi Risk Level (tetap)
    ══════════════════════════════════════════════ */
    const donutEl = document.getElementById('donutChart');
    if (donutEl) {
        new Chart(donutEl, {
            type : 'doughnut',
            data : {
                labels   : riskDist.map(d => d.label),
                datasets : [{
                    data            : riskDist.map(d => d.pct),
                    backgroundColor : [C.teal, C.amber, C.red],
                    borderColor     : C.white,
                    borderWidth     : 3,
                    hoverOffset     : 8,
                }],
            },
            options : {
                responsive          : true,
                maintainAspectRatio : false,
                cutout              : '72%',
                plugins : {
                    legend  : { display: false },
                    tooltip : { ...TOOLTIP, callbacks: { label: ctx => ` ${ctx.label}: ${ctx.parsed}%` } },
                },
            },
        });

        const legendEl = document.querySelector('.risk-legend');
        if (legendEl && legendEl.children.length === 0) {
            const colorMap = { teal: C.teal, amber: C.amber, red: C.red };
            riskDist.forEach(d => {
                legendEl.innerHTML += `
                    <div class="risk-legend-row">
                        <span class="risk-legend-label">
                            <span class="risk-legend-dot" style="background:${colorMap[d.color]}"></span>
                            ${d.label}
                        </span>
                        <span class="risk-legend-value" style="color:${colorMap[d.color]}">
                            ${d.pct}% · ${d.count} user
                        </span>
                    </div>`;
            });
        }
    }

    /* ══════════════════════════════════════════════
       3. PERBANDINGAN KATEGORI — Multi Line Chart
    ══════════════════════════════════════════════ */
    const groupedEl = document.getElementById('groupedBarChart');
    let groupedLineChart = null;

    function buildGroupedData(key) {
        const g = groupedBar[key] || groupedBar['byRole'];
        if (!g) return null;
        return {
            labels   : g.labels,
            datasets : [
                lineDataset('Rendah', g.rendah, C.teal,  false),
                lineDataset('Sedang', g.sedang, C.amber, false),
                lineDataset('Tinggi', g.tinggi, C.red,   false),
            ],
        };
    }

    function renderGroupedLine(key) {
        if (!groupedEl) return;
        const data = buildGroupedData(key);
        if (!data) return;
        if (groupedLineChart) {
            groupedLineChart.data = data;
            groupedLineChart.update('active');
        } else {
            groupedLineChart = new Chart(groupedEl, {
                type    : 'line',
                data,
                options : {
                    responsive          : true,
                    maintainAspectRatio : false,
                    interaction         : { mode: 'index', intersect: false },
                    plugins : {
                        legend : {
                            position : 'top',
                            labels   : { color:C.text, font:{ family:'DM Sans', size:11 }, boxWidth:12, padding:16, usePointStyle:true },
                        },
                        tooltip : { ...TOOLTIP, callbacks: { label: ctx => ` ${ctx.dataset.label}: ${ctx.parsed.y}%` } },
                    },
                    scales : {
                        x : AXIS(),
                        y : AXIS({ min:0, max:100, ticks:{ ...AXIS().ticks, callback: v => v+'%' } }),
                    },
                },
            });
        }
    }

    renderGroupedLine('byRole');

    document.getElementById('groupedBarSelect')?.addEventListener('change', e => {
        renderGroupedLine(e.target.value);
    });

    /* ══════════════════════════════════════════════
       4. SUBMISSIONS — Line Chart (Teal)
    ══════════════════════════════════════════════ */
    const submEl = document.getElementById('submissionsChart');
    if (submEl) {
        new Chart(submEl, {
            type : 'line',
            data : {
                labels   : dailySubmissions.labels,
                datasets : [lineDataset('Kuesioner Terisi', dailySubmissions.data, C.teal)],
            },
            options : {
                responsive          : true,
                maintainAspectRatio : false,
                interaction         : { mode: 'index', intersect: false },
                plugins : {
                    legend  : { display: false },
                    tooltip : { ...TOOLTIP, callbacks: { label: ctx => ` ${ctx.parsed.y} kuesioner` } },
                },
                scales : {
                    x : AXIS(),
                    y : AXIS({ beginAtZero:true, ticks:{ ...AXIS().ticks, precision:0, callback: v => v+' user' } }),
                },
            },
        });
    }

    /* ══════════════════════════════════════════════
       5. DISTRIBUSI SKOR — Line Chart
    ══════════════════════════════════════════════ */
    const histEl = document.getElementById('histogramChart');
    if (histEl) {
        const pointColors = scoreHistogram.labels.map(label => {
            const start = parseInt(label.split('–')[0].trim());
            if (start < 40) return C.teal;
            if (start < 70) return C.amber;
            return C.red;
        });

        new Chart(histEl, {
            type : 'line',
            data : {
                labels   : scoreHistogram.labels,
                datasets : [{
                    label                : 'Jumlah User',
                    data                 : scoreHistogram.data,
                    borderColor          : C.navy,
                    backgroundColor      : 'rgba(30,58,95,0.07)',
                    fill                 : true,
                    tension              : 0.4,
                    pointRadius          : 6,
                    pointBackgroundColor : pointColors,
                    pointBorderColor     : C.white,
                    pointBorderWidth     : 2,
                    borderWidth          : 2.5,
                }],
            },
            options : {
                responsive          : true,
                maintainAspectRatio : false,
                interaction         : { mode: 'index', intersect: false },
                plugins : {
                    legend  : { display: false },
                    tooltip : { ...TOOLTIP, callbacks: { label: ctx => ` ${ctx.parsed.y} user` } },
                },
                scales : {
                    x : AXIS(),
                    y : AXIS({ beginAtZero:true, ticks:{ ...AXIS().ticks, precision:0, callback: v => v+' user' } }),
                },
            },
        });
    }

});
</script>
@endpush