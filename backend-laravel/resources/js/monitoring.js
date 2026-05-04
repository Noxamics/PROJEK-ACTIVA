/**
 * public/js/monitoring.js
 * Activa Admin — Monitoring ML Charts
 * Depends on: Chart.js >= 4.4
 */

document.addEventListener('DOMContentLoaded', function () {

    /* ── FIX: Set score bar widths dari data-width attribute ──
       Menggantikan inline style="width:{{ }}%" yang
       menyebabkan CSS false-positive di VS Code.
    ─────────────────────────────────────────────────────────── */
    document.querySelectorAll('[data-width]').forEach(function (el) {
        el.style.width = el.dataset.width + '%';
    });

    /* ── Shared chart defaults (same pattern as dashboard.js) ── */
    const TOOLTIP = {
        backgroundColor : '#fff',
        borderColor     : '#E2EAF2',
        borderWidth     : 1,
        titleColor      : '#0F1F35',
        bodyColor       : '#4A6180',
        padding         : 10,
    };

    const GRID_AXIS = {
        grid  : { color: 'rgba(30,58,95,0.05)' },
        ticks : { color: '#8BA3BE', font: { family: 'DM Sans', size: 10 } },
    };

    /* ── Read data injected by Blade ───────────────────────── */
    const el          = document.getElementById('chart-data');
    const screenDist  = JSON.parse(el.dataset.screenDist);
    const radarData   = JSON.parse(el.dataset.radar);
    const trendData   = JSON.parse(el.dataset.trend);

    /* ── C1 · Bar — Screen Time Distribution ───────────────── */
    const c1 = document.getElementById('c1');

    if (c1) {
        new Chart(c1, {
            type : 'bar',
            data : {
                labels   : screenDist.labels,
                datasets : [{
                    label           : 'Jumlah User',
                    data            : screenDist.data,
                    backgroundColor : screenDist.colors ?? [
                        '#0D9488','#0D9488','#0D9488',
                        '#D97706','#E05252','#E05252',
                    ],
                    borderRadius    : 7,
                    borderSkipped   : false,
                }],
            },
            options : {
                responsive : true,
                plugins    : {
                    legend  : { display: false },
                    tooltip : TOOLTIP,
                },
                scales : { x: GRID_AXIS, y: GRID_AXIS },
            },
        });
    }

    /* ── C2 · Radar — Low vs High Risk Profile ─────────────── */
    const c2 = document.getElementById('c2');

    if (c2) {
        new Chart(c2, {
            type : 'radar',
            data : {
                labels   : radarData.labels ?? ['Focus','Productivity','Sleep','Physical','Social','Digital Health'],
                datasets : [
                    {
                        label               : 'Low Risk',
                        data                : radarData.low ?? [],
                        borderColor         : '#0D9488',
                        backgroundColor     : 'rgba(13,148,136,0.1)',
                        pointBackgroundColor: '#0D9488',
                        borderWidth         : 2.5,
                        pointRadius         : 4,
                    },
                    {
                        label               : 'High Risk',
                        data                : radarData.high ?? [],
                        borderColor         : '#E05252',
                        backgroundColor     : 'rgba(224,82,82,0.08)',
                        pointBackgroundColor: '#E05252',
                        borderWidth         : 2.5,
                        pointRadius         : 4,
                    },
                ],
            },
            options : {
                responsive : true,
                plugins    : {
                    legend  : {
                        labels : {
                            color    : '#4A6180',
                            font     : { family: 'DM Sans', size: 11 },
                            boxWidth : 12,
                        },
                    },
                    tooltip : TOOLTIP,
                },
                scales : {
                    r : {
                        grid        : { color: 'rgba(30,58,95,0.08)' },
                        angleLines  : { color: 'rgba(30,58,95,0.08)' },
                        ticks       : {
                            color          : '#8BA3BE',
                            backdropColor  : 'transparent',
                            font           : { family: 'DM Sans', size: 9 },
                        },
                        pointLabels : {
                            color  : '#4A6180',
                            font   : { family: 'DM Sans', size: 11, weight: '600' },
                        },
                        min : 0,
                        max : 100,
                    },
                },
            },
        });
    }

    /* ── C3 · Line — Monthly Trend ─────────────────────────── */
    const c3 = document.getElementById('c3');

    if (c3) {
        new Chart(c3, {
            type : 'line',
            data : {
                labels   : trendData.labels,
                datasets : [
                    {
                        label               : 'Focus Score',
                        data                : trendData.focus,
                        borderColor         : '#0D9488',
                        backgroundColor     : 'rgba(13,148,136,0.07)',
                        fill                : true,
                        tension             : 0.4,
                        pointRadius         : 4,
                        pointBackgroundColor: '#0D9488',
                        borderWidth         : 2.5,
                    },
                    {
                        label               : 'Productivity',
                        data                : trendData.productivity,
                        borderColor         : '#1E3A5F',
                        backgroundColor     : 'rgba(30,58,95,0.05)',
                        fill                : true,
                        tension             : 0.4,
                        pointRadius         : 4,
                        pointBackgroundColor: '#1E3A5F',
                        borderWidth         : 2,
                    },
                    {
                        label               : 'Dependence',
                        data                : trendData.dependence,
                        borderColor         : '#D97706',
                        backgroundColor     : 'rgba(217,119,6,0.05)',
                        fill                : true,
                        tension             : 0.4,
                        pointRadius         : 4,
                        pointBackgroundColor: '#D97706',
                        borderWidth         : 2,
                        borderDash          : [4, 4],
                    },
                ],
            },
            options : {
                responsive  : true,
                interaction : { mode: 'index', intersect: false },
                plugins     : {
                    legend  : {
                        labels : {
                            color    : '#4A6180',
                            font     : { family: 'DM Sans', size: 11 },
                            boxWidth : 12,
                        },
                    },
                    tooltip : TOOLTIP,
                },
                scales : {
                    x : GRID_AXIS,
                    y : { ...GRID_AXIS, min: 30, max: 100 },
                },
            },
        });
    }

});