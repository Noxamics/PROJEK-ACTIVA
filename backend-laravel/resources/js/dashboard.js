/**
 * public/js/dashboard.js
 * Activa Admin — Dashboard Charts (Complete)
 * Chart 1 (Score Trend)    : Bar chart, toggle Harian/Mingguan/Bulanan
 * Chart 2 (Risk Level)     : Doughnut chart
 * Chart 3 (Kategori)       : Grouped bar chart, dropdown filter
 * Chart 4 (Submissions)    : Bar chart harian
 * Chart 5 (Histogram)      : Bar chart distribusi skor
 * Palette: Navy #1E3A5F | Teal #0D9488 | Amber #D97706 | Red #E05252
 * Depends on: Chart.js >= 4.4
 */

document.addEventListener('DOMContentLoaded', function () {

    /* ── Design tokens ─────────────────────────────────────── */
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

    /* ── Read data bridge dari controller ──────────────────── */
    const el = document.getElementById('chart-data');

    const _riskDist         = el ? safeJson(el.dataset.riskDist,         [])                        : [];
    const _scoreTrend       = el ? safeJson(el.dataset.scoreTrend,       {})                        : {};
    const _groupedBar       = el ? safeJson(el.dataset.groupedBar,       {})                        : {};
    const _dailySubmissions = el ? safeJson(el.dataset.dailySubmissions, { labels: [], data: [] })  : { labels: [], data: [] };
    const _scoreHistogram   = el ? safeJson(el.dataset.scoreHistogram,   { labels: [], data: [] })  : { labels: [], data: [] };

    /* ── Data Dummy ─────────────────────────────────────────── */
    const DUMMY = {
        riskDist : [
            { label: 'Rendah', pct: 35, count: 45, color: 'teal'  },
            { label: 'Sedang', pct: 52, count: 66, color: 'amber' },
            { label: 'Tinggi', pct: 13, count: 17, color: 'red'   },
        ],
        scoreTrend : {
            daily   : { labels: ['Sen','Sel','Rab','Kam','Jum','Sab','Min'], data: [52,58,55,63,60,67,64] },
            weekly  : { labels: ['Mg 1','Mg 2','Mg 3','Mg 4'],              data: [54,57,61,65] },
            monthly : { labels: ['Jan','Feb','Mar','Apr','Mei','Jun'],       data: [48,52,55,59,62,65] },
        },
        groupedBar : {
            byRole   : { labels: ['Mahasiswa','Pekerja','Lainnya'],                         rendah: [30,42,28], sedang: [50,43,52], tinggi: [20,15,20] },
            byGender : { labels: ['Laki-laki','Perempuan'],                                 rendah: [30,40],    sedang: [50,54],    tinggi: [20,6]    },
            byAge    : { labels: ['< 18','18–24','25–34','35–44','45+'],                    rendah: [20,28,38,45,50], sedang: [55,52,48,42,38], tinggi: [25,20,14,13,12] },
            byRegion : { labels: ['Jawa','Sumatera','Kalimantan','Sulawesi','Lainnya'],     rendah: [33,36,40,38,42], sedang: [52,50,48,50,46], tinggi: [15,14,12,12,12] },
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

    /* Fallback ke dummy jika data controller kosong */
    const riskDist         = _riskDist.length              > 0 ? _riskDist         : DUMMY.riskDist;
    const scoreTrend       = Object.keys(_scoreTrend).length   > 0 ? _scoreTrend   : DUMMY.scoreTrend;
    const groupedBar       = Object.keys(_groupedBar).length   > 0 ? _groupedBar   : DUMMY.groupedBar;
    const dailySubmissions = _dailySubmissions.labels?.length  > 0 ? _dailySubmissions : DUMMY.dailySubmissions;
    const scoreHistogram   = _scoreHistogram.labels?.length    > 0 ? _scoreHistogram   : DUMMY.scoreHistogram;

    /* Helper: warna selang-seling navy per bar */
    function altColors(n) {
        return Array.from({ length: n }, (_, i) => i % 2 === 0 ? C.navy : C.navyLt);
    }

    /* ═══════════════════════════════════════════════════════
       1. SCORE TREND — Bar Chart
    ═══════════════════════════════════════════════════════ */
    const trendEl = document.getElementById('scoreTrendChart');
    let scoreTrendChart = null;

    function buildTrendData(period) {
        const src = scoreTrend[period] || scoreTrend['daily'];
        return {
            labels   : src.labels,
            datasets : [{
                label           : 'Avg. Skor',
                data            : src.data,
                backgroundColor : altColors(src.data.length),
                borderRadius    : 5,
                borderSkipped   : false,
            }],
        };
    }

    function renderScoreTrend(period) {
        if (!trendEl) return;
        if (scoreTrendChart) {
            scoreTrendChart.data = buildTrendData(period);
            scoreTrendChart.update('active');
        } else {
            scoreTrendChart = new Chart(trendEl, {
                type    : 'bar',
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
                        y : AXIS({ min: 0, max: 100, ticks: { ...AXIS().ticks, callback: v => v } }),
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

    /* ═══════════════════════════════════════════════════════
       2. DONUT — Distribusi Risk Level
    ═══════════════════════════════════════════════════════ */
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

        /* Render legend dinamis jika blade tidak merender (data kosong dari controller) */
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

    /* ═══════════════════════════════════════════════════════
       3. GROUPED BAR — Perbandingan Kategori
    ═══════════════════════════════════════════════════════ */
    const groupedEl = document.getElementById('groupedBarChart');
    let groupedBarChart = null;

    function buildGroupedData(key) {
        const g = groupedBar[key] || groupedBar['byRole'];
        if (!g) return null;
        return {
            labels   : g.labels,
            datasets : [
                { label: 'Rendah', data: g.rendah, backgroundColor: C.teal,  borderRadius: 4, borderSkipped: false },
                { label: 'Sedang', data: g.sedang, backgroundColor: C.amber, borderRadius: 4, borderSkipped: false },
                { label: 'Tinggi', data: g.tinggi, backgroundColor: C.red,   borderRadius: 4, borderSkipped: false },
            ],
        };
    }

    function renderGroupedBar(key) {
        if (!groupedEl) return;
        const data = buildGroupedData(key);
        if (!data) return;
        if (groupedBarChart) {
            groupedBarChart.data = data;
            groupedBarChart.update('active');
        } else {
            groupedBarChart = new Chart(groupedEl, {
                type    : 'bar',
                data,
                options : {
                    responsive          : true,
                    maintainAspectRatio : false,
                    interaction         : { mode: 'index', intersect: false },
                    plugins : {
                        legend : {
                            position : 'top',
                            labels   : { color: C.text, font: { family: 'DM Sans', size: 11 }, boxWidth: 12, padding: 16 },
                        },
                        tooltip : { ...TOOLTIP, callbacks: { label: ctx => ` ${ctx.dataset.label}: ${ctx.parsed.y}%` } },
                    },
                    scales : {
                        x : AXIS(),
                        y : AXIS({ min: 0, max: 100, ticks: { ...AXIS().ticks, callback: v => v + '%' } }),
                    },
                },
            });
        }
    }

    renderGroupedBar('byRole');

    document.getElementById('groupedBarSelect')?.addEventListener('change', e => {
        renderGroupedBar(e.target.value);
    });

    /* ═══════════════════════════════════════════════════════
       4. SUBMISSIONS — Bar Chart (Teal)
    ═══════════════════════════════════════════════════════ */
    const submEl = document.getElementById('submissionsChart');
    if (submEl) {
        new Chart(submEl, {
            type : 'bar',
            data : {
                labels   : dailySubmissions.labels,
                datasets : [{
                    label           : 'Kuesioner Terisi',
                    data            : dailySubmissions.data,
                    backgroundColor : C.teal,
                    borderRadius    : 5,
                    borderSkipped   : false,
                }],
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
                    y : AXIS({ beginAtZero: true, ticks: { ...AXIS().ticks, precision: 0, callback: v => v + ' user' } }),
                },
            },
        });
    }

    /* ═══════════════════════════════════════════════════════
       5. HISTOGRAM — Distribusi Skor
       Teal=0–39, Amber=40–69, Red=70–100
    ═══════════════════════════════════════════════════════ */
    const histEl = document.getElementById('histogramChart');
    if (histEl) {
        const binColors = scoreHistogram.labels.map(label => {
            const start = parseInt(label.split('–')[0].trim());
            if (start < 40) return C.teal;
            if (start < 70) return C.amber;
            return C.red;
        });

        new Chart(histEl, {
            type : 'bar',
            data : {
                labels   : scoreHistogram.labels,
                datasets : [{
                    label              : 'Jumlah User',
                    data               : scoreHistogram.data,
                    backgroundColor    : binColors,
                    borderRadius       : 4,
                    borderSkipped      : false,
                    categoryPercentage : 0.9,
                    barPercentage      : 0.85,
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
                    y : AXIS({ beginAtZero: true, ticks: { ...AXIS().ticks, precision: 0, callback: v => v + ' user' } }),
                },
            },
        });
    }

});