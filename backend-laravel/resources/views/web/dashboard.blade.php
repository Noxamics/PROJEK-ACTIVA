@extends('web.layouts.app')
@section('title', 'Dashboard')

@section('styles')
<style>
    
/* ── Background base ── */
body {
    background: #f1f4f8 !important;
}
 
/* ── Dot-grid texture + ambient glow blobs (via pseudo-element) ── */
body::before {
    content: '';
    position: fixed;
    inset: 0;
    z-index: -10;
    pointer-events: none;
 
    /* Dot grid */
    background-color: #e8eef7;
    background-image:
        radial-gradient(circle, rgba(11,40,60,0.065) 1px, transparent 1px);
    background-size: 26px 26px;
}
 
body::after {
    content: '';
    position: fixed;
    inset: 0;
    z-index: -9;
    pointer-events: none;
 
    /* Ambient glow blobs — teal kiri, navy kanan, dll. */
    background:
        radial-gradient(ellipse 540px 440px at -6% -2%,  rgba(13,148,136,.15)  0%, transparent 68%),
        radial-gradient(ellipse 420px 360px at 104%  4%,  rgba(11, 20, 80,.12)  0%, transparent 68%),
        radial-gradient(ellipse 380px 380px at  10% 60%,  rgba(20,184,166,.09)  0%, transparent 65%),
        radial-gradient(ellipse 500px 400px at 100% 100%, rgba(15, 38,100,.12)  0%, transparent 70%),
        radial-gradient(ellipse 620px 280px at  52% 44%,  rgba(13,148,136,.05)  0%, transparent 68%);
}
 
/* ── SVG decorative layer ── */
#dash-bg-svg {
    position: fixed;
    inset: 0;
    width: 100%;
    height: 100%;
    z-index: -8;
    pointer-events: none;
    overflow: hidden;
}

/* ══ Score Card — Flutter style ══ */
.score-card-wrap {
    background: linear-gradient(135deg, var(--bg-dark) 0%, #1E3A5F 60%, var(--bg-card) 100%);
    border: 1px solid var(--border-card);
    border-radius: var(--radius-2xl);
    padding: 36px 40px;
    position: relative;
    overflow: hidden;
}
/* Decorative blobs */
.score-card-wrap::before {
    content: '';
    position: absolute;
    top: -60px; right: -60px;
    width: 240px; height: 240px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(13,148,136,.18) 0%, transparent 70%);
    pointer-events: none;
}
.score-card-wrap::after {
    content: '';
    position: absolute;
    bottom: -40px; left: 100px;
    width: 180px; height: 180px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(59,130,246,.08) 0%, transparent 70%);
    pointer-events: none;
}
/* Floating dots */
.score-deco-dot {
    position: absolute;
    border-radius: 50%;
    opacity: .35;
    pointer-events: none;
}

/* Score number big */
.score-big-num {
    font-size: 4rem;
    font-weight: 900;
    letter-spacing: -.06em;
    line-height: 1;
}
.score-of-100 {
    font-size: 1.125rem;
    font-weight: 600;
    color: rgba(255,255,255,.4);
    margin-left: 4px;
}

/* Horizontal progress bar */
.score-hbar-wrap {
    height: 8px;
    background: rgba(255,255,255,.1);
    border-radius: 99px;
    overflow: hidden;
    margin: 14px 0 10px;
}
.score-hbar-fill {
    height: 100%;
    border-radius: 99px;
    transition: width 1.4s cubic-bezier(.16,1,.3,1);
}

/* AI insight chip */
.score-insight-chip {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    background: rgba(255,255,255,.07);
    border: 1px solid rgba(255,255,255,.1);
    border-radius: var(--radius-lg);
    padding: 12px 16px;
    margin-top: 16px;
}
.score-insight-chip-icon {
    width: 30px; height: 30px;
    border-radius: var(--radius-sm);
    background: rgba(13,148,136,.25);
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
}

/* Right gauge (small ring) — like Flutter ref */
.mini-gauge-wrap {
    position: relative;
    width: 120px; height: 120px;
    flex-shrink: 0;
}
.mini-gauge-wrap svg {
    width: 120px; height: 120px;
    transform: rotate(-90deg);
}
.mini-gauge-center {
    position: absolute; inset: 0;
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    gap: 2px;
}
.mini-gauge-pct {
    font-size: 1.375rem;
    font-weight: 900;
    letter-spacing: -.04em;
    color: #fff;
}
.mini-gauge-lbl {
    font-size: .625rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .08em;
    color: rgba(255,255,255,.45);
}

/* ══ Donut Chart Upgrade ══ */
.donut-card {
    position: relative;
}
.donut-outer {
    position: relative;
    width: 130px; height: 130px;
    flex-shrink: 0;
}
.donut-outer svg {
    width: 130px; height: 130px;
    transform: rotate(-90deg);
    filter: drop-shadow(0 4px 12px rgba(0,0,0,.1));
}
.donut-inner-text {
    position: absolute; inset: 0;
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    gap: 0;
}
.donut-inner-num {
    font-size: 1.625rem;
    font-weight: 900;
    letter-spacing: -.05em;
    color: var(--text-dark);
    line-height: 1;
}
.donut-inner-lbl {
    font-size: .6rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .07em;
    color: var(--text-muted);
    margin-top: 2px;
}

/* Legend item with mini bar */
.cat-legend-row {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 8px 10px;
    border-radius: var(--radius-md);
    transition: background .15s;
}
.cat-legend-row:hover { background: rgba(13,148,136,.04); }
.cat-dot-lg {
    width: 12px; height: 12px;
    border-radius: 50%;
    flex-shrink: 0;
    box-shadow: 0 2px 6px rgba(0,0,0,.15);
}
.cat-bar-mini {
    flex: 1;
    height: 5px;
    background: var(--border-light);
    border-radius: 99px;
    overflow: hidden;
}
.cat-bar-fill {
    height: 100%;
    border-radius: 99px;
    transition: width .8s cubic-bezier(.16,1,.3,1);
}

/* ══ Realistic SVG Fire Animation ══ */
@keyframes fireBgGlow {
    0%, 100% { box-shadow: 0 0 15px rgba(255, 120, 0, 0.2), inset 0 0 15px rgba(255, 255, 255, 0.2); background: rgba(255, 140, 0, 0.15); }
    50% { box-shadow: 0 0 35px rgba(255, 100, 0, 0.6), inset 0 0 25px rgba(255, 255, 255, 0.4); background: rgba(255, 110, 0, 0.3); border-color: rgba(255, 160, 0, 0.7); }
}

.streak-fire-container-lit {
    width: 64px; height: 64px; border-radius: 50%; 
    display: flex; align-items: center; justify-content: center;
    border: 1px solid rgba(255, 140, 0, 0.4);
    animation: fireBgGlow 2.5s infinite ease-in-out;
}

.streak-fire-container-dim {
    width: 64px; height: 64px; border-radius: 50%; 
    display: flex; align-items: center; justify-content: center;
    background: rgba(255,255,255,0.08);
}

.modern-fire-svg {
    width: 44px;
    height: 44px;
    overflow: visible;
}
.modern-fire-svg .fire-layer-1 {
    transform-origin: 50% 95%;
    animation: fireSway1 2s infinite ease-in-out alternate;
}
.modern-fire-svg .fire-layer-2 {
    transform-origin: 50% 95%;
    animation: fireSway2 1.6s infinite ease-in-out alternate;
}
.modern-fire-svg .fire-layer-3 {
    transform-origin: 50% 95%;
    animation: fireSway3 1.2s infinite ease-in-out alternate;
}

@keyframes fireSway1 {
    0%   { transform: scaleY(1) scaleX(1) rotate(-2deg); }
    100% { transform: scaleY(1.03) scaleX(0.97) rotate(2deg); }
}
@keyframes fireSway2 {
    0%   { transform: scaleY(1) scaleX(1) rotate(3deg); }
    100% { transform: scaleY(1.06) scaleX(0.94) rotate(-3deg); }
}
@keyframes fireSway3 {
    0%   { transform: scaleY(1) scaleX(1) rotate(-4deg); }
    100% { transform: scaleY(1.1) scaleX(0.9) rotate(4deg); }
}

.streak-fire-dim-svg {
    filter: grayscale(100%) opacity(0.3);
}
.streak-fire-dim-svg .fire-layer-1,
.streak-fire-dim-svg .fire-layer-2,
.streak-fire-dim-svg .fire-layer-3 {
    animation: none !important;
}

/* ══ Hover Animations (Float & Glow) matching Histori & Profil ══ */
.score-card-wrap {
    transition: transform 0.25s cubic-bezier(0.4,0,0.2,1), box-shadow 0.25s, border-color 0.25s !important;
}
.score-card-wrap:hover {
    transform: translateY(-4px);
    border-color: rgba(0,229,200,0.4) !important;
    box-shadow: 0 12px 40px rgba(0,229,200,0.15), 0 4px 12px rgba(0,0,0,0.3) !important;
}

.card {
    transition: transform 0.25s cubic-bezier(0.4,0,0.2,1), box-shadow 0.25s, border-color 0.25s !important;
}
.card:hover {
    transform: translateY(-4px);
    border-color: rgba(0,229,200,0.4) !important;
    box-shadow: 0 12px 40px rgba(0,229,200,0.15), 0 4px 12px rgba(0,0,0,0.1) !important;
}

.habit-row, .tip-row {
    transition: transform 0.2s, background 0.2s;
}
.habit-row:hover, .tip-row:hover {
    transform: translateX(4px);
}
</style>
@endsection

@section('content')
@php
    $hour = (int)date('H');
    $greeting = $hour < 11 ? 'Selamat Pagi' : ($hour < 15 ? 'Selamat Siang' : ($hour < 18 ? 'Selamat Sore' : 'Selamat Malam'));

    $score      = $latestMl ? ($latestMl->ml_result['digital_dependence_score'] ?? 0) : null;
    $confRaw    = $latestMl ? ($latestMl->ml_result['confidence'] ?? 0) : null;
    $confidence = is_array($confRaw)
                    ? ($confRaw['confidence_final_pct'] ?? 0)
                    : (is_numeric($confRaw) ? (float)$confRaw : null);
    $ai         = $latestMl ? ($latestMl->ai_analysis ?? []) : [];

    $scoreColor     = $score !== null ? ($score < 33.47 ? '#22C55E' : ($score <= 61.34 ? '#F59E0B' : '#EF4444')) : '#64748B';
    $scoreColorVar  = $score !== null ? ($score < 33.47 ? 'var(--green)' : ($score <= 61.34 ? 'var(--amber)' : 'var(--red)')) : 'var(--text-muted)';
    $scoreCat       = $score !== null ? ($score < 33.47 ? 'Rendah' : ($score <= 61.34 ? 'Sedang' : 'Tinggi')) : '-';
    $scoreBadge     = $score !== null ? ($score < 33.47 ? 'badge-green' : ($score <= 61.34 ? 'badge-amber' : 'badge-red')) : 'badge-blue';
    $scoreBarPct    = $score !== null ? round($score) : 0;

    // Mini gauge
    $mgCirc   = 2 * 3.14159 * 46;
    $mgOffset = $score !== null ? $mgCirc - ($score / 100) * $mgCirc : $mgCirc;

    // Dummy data
    $screenTimeHours = 9.3;
    $sleepHours      = 6.5;
    // $totalKuesioner dari controller
    if (!isset($totalKuesioner)) {
        $totalKuesioner = 0;
    }

    $catRendah = 29; $catRendahCount = 2;
    $catSedang = 57; $catSedangCount = 4;
    $catTinggi = 14; $catTinggiCount = 1;

    // Donut
    $r2   = 46; $circ2 = 2 * 3.14159 * $r2;
    $rD   = ($catRendah / 100) * $circ2;
    $sD   = ($catSedang / 100) * $circ2;
    $tD   = ($catTinggi / 100) * $circ2;
    $sOff = -$rD;
    $tOff = -$rD - $sD;

    // Dynamic Habits based on latest questionnaire
    $habits = [
        ['label' => 'Tidur minimal 7 jam',             'done' => $latestQ ? ($latestQ->sleep_hours >= 7) : false],
        ['label' => 'Screen time < 6 jam',             'done' => $latestQ ? ($latestQ->device_hours_per_day < 6) : false],
        ['label' => 'Tingkat ketergantungan rendah',   'done' => $score !== null ? ($score < 33.47) : false],
        ['label' => 'Kualitas tidur terjaga',          'done' => $latestQ ? ($latestQ->sleep_quality >= 4.0) : false],
    ];
    $habitsDone  = collect($habits)->where('done', true)->count();
    $habitsTotal = count($habits);

    // Dynamic Tips based on latest questionnaire
    $tips = [];
    if ($latestQ) {
        if ($latestQ->sleep_hours < 7) {
            $tips[] = [
                'text' => 'Tidur yang cukup sangat penting. Cobalah tidur 30 menit lebih awal malam ini.',
                'color' => 'var(--blue)', 'bg' => 'rgba(59,130,246,.1)',
                'icon' => '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>'
            ];
        }
        if ($latestQ->device_hours_per_day >= 6) {
            $tips[] = [
                'text' => 'Screen time Anda cukup tinggi. Terapkan aturan 20-20-20 untuk istirahatkan mata.',
                'color' => 'var(--amber)', 'bg' => 'rgba(245,158,11,.1)',
                'icon' => '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>'
            ];
        }
        if ($latestQ->social_media_mins >= 60) {
            $tips[] = [
                'text' => 'Batasi media sosial. Matikan notifikasi non-esensial selama 2 jam saat bekerja.',
                'color' => 'var(--amber)', 'bg' => 'rgba(245,158,11,.1)',
                'icon' => '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M18 8h1a4 4 0 0 1 0 8h-1"/><path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z"/><line x1="6" y1="1" x2="6" y2="4"/><line x1="10" y1="1" x2="10" y2="4"/><line x1="14" y1="1" x2="14" y2="4"/></svg>'
            ];
        }
        if ($latestQ->physical_activity_days < 3) {
            $tips[] = [
                'text' => 'Luangkan 15 menit jalan kaki tanpa melihat smartphone hari ini.',
                'color' => 'var(--green)', 'bg' => 'rgba(34,197,94,.1)',
                'icon' => '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg>'
            ];
        }
    }
    
    // Fallback if no issues found or no questionnaire
    if (empty($tips)) {
        if (!$latestQ) {
            $tips[] = [
                'text' => 'Isi kuesioner pertama Anda untuk mendapatkan tips harian yang dipersonalisasi.',
                'color' => 'var(--teal)', 'bg' => 'rgba(13,148,136,.1)',
                'icon' => '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>'
            ];
        } else {
            $tips[] = [
                'text' => 'Bagus! Pertahankan kebiasaan sehat dan disiplin digital Anda saat ini.',
                'color' => 'var(--green)', 'bg' => 'rgba(34,197,94,.1)',
                'icon' => '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><polyline points="20 6 9 17 4 12"/></svg>'
            ];
            $tips[] = [
                'text' => 'Sesekali jauhkan ponsel saat sedang berkumpul santai bersama keluarga.',
                'color' => 'var(--purple)', 'bg' => 'rgba(139,92,246,.1)',
                'icon' => '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>'
            ];
        }
    }
    
    // Pick up to 3 tips
    shuffle($tips);
    $tips = array_slice($tips, 0, 3);
@endphp

{{-- ─── Page Header ─── --}}
<div class="page-header anim-fade">
    <h1>
        @if($hour < 11)
            <svg style="display:inline;vertical-align:-5px;margin-right:6px" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="var(--amber)" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
        @elseif($hour < 18)
            <svg style="display:inline;vertical-align:-5px;margin-right:6px" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="var(--amber)" stroke-width="2" stroke-linecap="round"><path d="M17 18a5 5 0 0 0-10 0"/><line x1="12" y1="2" x2="12" y2="9"/><line x1="4.22" y1="10.22" x2="5.64" y2="11.64"/><line x1="1" y1="18" x2="3" y2="18"/><line x1="21" y1="18" x2="23" y2="18"/><line x1="18.36" y1="11.64" x2="19.78" y2="10.22"/></svg>
        @else
            <svg style="display:inline;vertical-align:-5px;margin-right:6px" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" stroke-width="2" stroke-linecap="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
        @endif
        {{ $greeting }}, {{ explode(' ', $user->name)[0] }}!
    </h1>
    <p>Pantau dan tingkatkan gaya hidup digitalmu hari ini</p>
</div>

{{-- ════ SCORE CARD (Flutter-style) ════ --}}
<div class="anim-up d1" style="margin-bottom:24px;">
    <div class="score-card-wrap">

        {{-- Decorative dots --}}
        <span class="score-deco-dot" style="width:6px;height:6px;background:{{ $scoreColor }};top:28px;left:52%;"></span>
        <span class="score-deco-dot" style="width:10px;height:10px;background:rgba(59,130,246,.5);top:60px;right:200px;"></span>
        <span class="score-deco-dot" style="width:5px;height:5px;background:rgba(255,255,255,.3);bottom:40px;left:38%;"></span>
        <span class="score-deco-dot" style="width:8px;height:8px;background:rgba(13,148,136,.4);bottom:24px;right:260px;"></span>

        <div style="display:flex;align-items:flex-start;gap:32px;flex-wrap:wrap;position:relative;z-index:1;">

            {{-- Left: Score info --}}
            <div style="flex:1;min-width:240px;">
                <div style="font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.1em;color:rgba(255,255,255,.45);margin-bottom:10px;">
                    Skor Ketergantungan Digital
                </div>

                @if($score !== null)
                    {{-- Big number --}}
                    <div style="display:flex;align-items:baseline;gap:0;margin-bottom:4px;">
                        <span class="score-big-num" style="color:{{ $scoreColor }}">{{ round($score) }}</span>
                        <span class="score-of-100">/ 100</span>
                    </div>

                    {{-- Category badge --}}
                    <div style="margin-bottom:4px;">
                        <span class="badge {{ $scoreBadge }}">
                            <svg width="8" height="8" viewBox="0 0 8 8"><circle cx="4" cy="4" r="4" fill="currentColor"/></svg>
                            {{ $scoreCat }}
                        </span>
                    </div>

                    {{-- Horizontal bar --}}
                    <div class="score-hbar-wrap">
                        <div class="score-hbar-fill" id="scoreHBar"
                             style="width:0%;background:linear-gradient(90deg, {{ $scoreColor }}99, {{ $scoreColor }});">
                        </div>
                    </div>
                    <div style="display:flex;justify-content:space-between;font-size:.7rem;color:rgba(255,255,255,.3);">
                        <span>0</span><span>Rendah</span><span>Sedang</span><span>Tinggi</span><span>100</span>
                    </div>

                    {{-- AI insight chip --}}
                    <div class="score-insight-chip" style="margin-top:18px;">
                        <div class="score-insight-chip-icon">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--teal)" stroke-width="2.2"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                        </div>
                        <p style="font-size:.8125rem;color:rgba(255,255,255,.7);line-height:1.6;margin:0;">
                            {{ $ai['pembukaan'] ?? $ai['summary'] ?? 'Skor ini menunjukkan tingkat ketergantungan digitalmu saat ini. Lakukan kuesioner secara rutin untuk hasil yang lebih akurat.' }}
                        </p>
                    </div>

                    <div style="margin-top:20px;">
                        <a href="{{ url('/user/kuesioner') }}" class="btn btn-primary btn-sm">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                            Isi Kuesioner Baru
                        </a>
                    </div>

                @else
                    {{-- Empty state --}}
                    <h2 style="color:#fff;margin-bottom:12px;font-size:1.5rem;">Skor Ketergantungan Digital</h2>
                    <p style="color:rgba(255,255,255,.55);line-height:1.8;margin-bottom:24px;font-size:.9375rem;">
                        Isi kuesioner pertamamu untuk mendapatkan skor analisis berbasis Machine Learning dan AI.
                    </p>
                    <a href="{{ url('/user/kuesioner') }}" class="btn btn-primary">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                        Mulai Kuesioner
                    </a>
                @endif
            </div>

            {{-- Right: Mini ring gauge (like Flutter reference) --}}
            <div style="display:flex;flex-direction:column;align-items:center;gap:12px;padding-top:4px;">
                <div class="mini-gauge-wrap">
                    <svg viewBox="0 0 120 120">
                        {{-- Shadow ring --}}
                        <circle cx="60" cy="60" r="46" fill="none" stroke="rgba(255,255,255,.06)" stroke-width="12"/>
                        {{-- Track --}}
                        <circle cx="60" cy="60" r="46" fill="none" stroke="rgba(255,255,255,.08)" stroke-width="10"/>
                        @if($score !== null)
                        {{-- Fill --}}
                        <circle cx="60" cy="60" r="46" fill="none"
                            stroke="{{ $scoreColor }}" stroke-width="10" stroke-linecap="round"
                            stroke-dasharray="{{ $mgCirc }}"
                            stroke-dashoffset="{{ $mgOffset }}"
                            id="miniGaugeCircle"
                            style="transition:stroke-dashoffset 1.5s cubic-bezier(.16,1,.3,1);filter:drop-shadow(0 0 6px {{ $scoreColor }}88)"/>
                        @endif
                        {{-- Inner glow circle --}}
                        <circle cx="60" cy="60" r="32" fill="rgba(255,255,255,.03)" stroke="rgba(255,255,255,.06)" stroke-width="1"/>
                    </svg>
                    <div class="mini-gauge-center">
                        @if($score !== null)
                            <div class="mini-gauge-pct" style="color:{{ $scoreColor }}">{{ round($score) }}%</div>
                            <div class="mini-gauge-lbl">{{ $scoreCat }}</div>
                        @else
                            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.3)" stroke-width="1.5"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            <div class="mini-gauge-lbl" style="margin-top:4px;text-align:center;">Belum<br>ada data</div>
                        @endif
                    </div>
                </div>
                @if($score !== null)
                    <div style="text-align:center;">
                        <div style="font-size:.7rem;color:rgba(255,255,255,.35);text-transform:uppercase;letter-spacing:.08em;">Digital Score</div>
                    </div>
                @endif
            </div>

        </div>
    </div>
</div>

{{-- ════ Stat Tiles ════ --}}
<div class="dash-grid" style="margin-bottom:24px;">
    {{-- Screen Time --}}
    <div class="anim-up d2">
        <div class="card card-p">
            <div style="display:flex;align-items:flex-start;gap:14px;">
                <div style="width:46px;height:46px;border-radius:var(--radius-md);background:rgba(245,158,11,.1);display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--amber)" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                </div>
                <div style="flex:1;">
                    <div style="font-size:.7rem;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.08em;margin-bottom:6px;">Screen Time</div>
                    <div style="font-size:2.25rem;font-weight:900;letter-spacing:-.04em;color:var(--text-dark);line-height:1;">
                        {{ $screenTimeHours }}<span style="font-size:.9375rem;font-weight:600;color:var(--text-muted);margin-left:4px;">Jam</span>
                    </div>
                    <div style="margin-top:8px;">
                        <span class="badge badge-amber" style="font-size:.7rem;padding:3px 10px;">Di atas target</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- Durasi Tidur --}}
    <div class="anim-up d3">
        <div class="card card-p">
            <div style="display:flex;align-items:flex-start;gap:14px;">
                <div style="width:46px;height:46px;border-radius:var(--radius-md);background:rgba(59,130,246,.1);display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" stroke-width="2"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
                </div>
                <div style="flex:1;">
                    <div style="font-size:.7rem;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.08em;margin-bottom:6px;">Durasi Tidur</div>
                    <div style="font-size:2.25rem;font-weight:900;letter-spacing:-.04em;color:var(--text-dark);line-height:1;">
                        {{ $sleepHours }}<span style="font-size:.9375rem;font-weight:600;color:var(--text-muted);margin-left:4px;">Jam</span>
                    </div>
                    <div style="margin-top:8px;">
                        <span class="badge badge-blue" style="font-size:.7rem;padding:3px 10px;">Kurang ideal</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

{{-- ════ Streak Banner ════ --}}
<div class="anim-up d3" style="margin-bottom:24px;">
    <div style="background:linear-gradient(135deg,var(--teal-dark),var(--teal),#0ea5e9);border-radius:var(--radius-xl);padding:20px 28px;display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;position:relative;overflow:hidden;">
        <span style="position:absolute;right:-20px;top:-20px;width:110px;height:110px;background:rgba(255,255,255,.07);border-radius:50%;pointer-events:none;"></span>
        <span style="position:absolute;right:80px;bottom:-30px;width:80px;height:80px;background:rgba(255,255,255,.04);border-radius:50%;pointer-events:none;"></span>
        <div style="display:flex;align-items:center;gap:16px;position:relative;z-index:1;">
            <div style="width:46px;height:46px;border-radius:50%;background:rgba(255,255,255,.15);display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.95)" stroke-width="2.2"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
            </div>
            <div>
                <div style="font-size:1.0625rem;font-weight:800;color:#fff;margin-bottom:2px;">{{ $streak }} Hari Streak</div>
                <div style="font-size:.8125rem;color:rgba(255,255,255,.75);">
                    @if($streak >= 3)
                        Kebiasaan sehatmu mulai terbentuk. Pertahankan!
                    @elseif($streak > 0)
                        Terus berlanjut! Selesaikan {{ 3 - $streak }} hari lagi agar api menyala.
                    @else
                        Mulai kebiasaan sehatmu hari ini. Jangan sampai bolong!
                    @endif
                </div>
            </div>
        </div>
        <div style="display:flex;align-items:center;gap:8px;position:relative;z-index:1;">
            @if($streak >= 3)
                {{-- Nyala (Lit) - Butuh minimal 3 hari --}}
                <div class="streak-fire-container-lit">
                    <svg viewBox="0 0 100 100" class="modern-fire-svg">
                        <defs>
                            <linearGradient id="fireOuter" x1="0%" y1="0%" x2="0%" y2="100%">
                                <stop offset="0%" stop-color="#ef4444"/>
                                <stop offset="100%" stop-color="#b91c1c"/>
                            </linearGradient>
                            <linearGradient id="fireMid" x1="0%" y1="0%" x2="0%" y2="100%">
                                <stop offset="0%" stop-color="#f97316"/>
                                <stop offset="100%" stop-color="#ea580c"/>
                            </linearGradient>
                            <linearGradient id="fireInner" x1="0%" y1="0%" x2="0%" y2="100%">
                                <stop offset="0%" stop-color="#fde047"/>
                                <stop offset="100%" stop-color="#f59e0b"/>
                            </linearGradient>
                            <filter id="fireGlow" x="-20%" y="-20%" width="140%" height="140%">
                                <feGaussianBlur stdDeviation="3" result="blur" />
                                <feMerge>
                                    <feMergeNode in="blur" />
                                    <feMergeNode in="SourceGraphic" />
                                </feMerge>
                            </filter>
                        </defs>
                        <g filter="url(#fireGlow)">
                            <path class="fire-layer-1" fill="url(#fireOuter)" d="M 50,5 Q 35,35 30,50 Q 25,40 20,40 C 0,70 15,95 50,95 C 85,95 100,70 80,40 Q 75,40 70,50 Q 65,35 50,5 Z" />
                            <path class="fire-layer-2" fill="url(#fireMid)" d="M 50,30 Q 40,50 35,65 Q 30,55 27,55 C 15,75 25,95 50,95 C 75,95 85,75 73,55 Q 70,55 65,65 Q 60,50 50,30 Z" />
                            <path class="fire-layer-3" fill="url(#fireInner)" d="M 50,55 Q 40,65 38,75 C 35,90 45,95 50,95 C 55,95 65,90 62,75 Q 60,65 50,55 Z" />
                        </g>
                    </svg>
                </div>
            @else
                {{-- Padam (Dim) --}}
                <div class="streak-fire-container-dim">
                    <svg viewBox="0 0 100 100" class="modern-fire-svg streak-fire-dim-svg">
                        <path class="fire-layer-1" fill="#ef4444" d="M 50,5 Q 35,35 30,50 Q 25,40 20,40 C 0,70 15,95 50,95 C 85,95 100,70 80,40 Q 75,40 70,50 Q 65,35 50,5 Z" />
                        <path class="fire-layer-2" fill="#f97316" d="M 50,30 Q 40,50 35,65 Q 30,55 27,55 C 15,75 25,95 50,95 C 75,95 85,75 73,55 Q 70,55 65,65 Q 60,50 50,30 Z" />
                        <path class="fire-layer-3" fill="#fde047" d="M 50,55 Q 40,65 38,75 C 35,90 45,95 50,95 C 55,95 65,90 62,75 Q 60,65 50,55 Z" />
                    </svg>
                </div>
            @endif
        </div>
    </div>
</div>

{{-- ════ ROW 2 — Insight + Kategori (upgraded donut) + Habit ════ --}}
<div class="dash-grid" style="grid-template-columns:1fr 1fr 1fr;margin-bottom:24px;">

    {{-- Weekly Insight --}}
    <div class="anim-up d4">
        <div class="card card-p" style="height:100%;position:relative;border-radius:var(--radius-2xl, 24px);">
            @if($totalKuesioner < 14)
                <div style="position:absolute;inset:0;z-index:10;background:rgba(255,255,255,0.65);backdrop-filter:blur(4px);border-radius:inherit;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:20px;">
                    <div style="width:48px;height:48px;border-radius:50%;background:rgba(15,23,42,0.05);display:flex;align-items:center;justify-content:center;margin-bottom:12px;">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--text-muted, #64748B)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                    </div>
                    <div style="font-size:1.0625rem;font-weight:800;color:var(--text-dark, #0F172A);margin-bottom:6px;">Insight Terkunci</div>
                    <div style="font-size:0.8125rem;color:var(--text-muted, #64748B);line-height:1.5;">Isi <strong>{{ 14 - $totalKuesioner }}</strong> kuesioner lagi<br>untuk membuka Insight Mingguan.</div>
                </div>
            @endif
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
                <div style="width:40px;height:40px;border-radius:var(--radius-md);background:rgba(59,130,246,.08);display:flex;align-items:center;justify-content:center;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" stroke-width="2.2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                </div>
                <div>
                    <h3 style="color:var(--text-dark);">Insight Mingguan</h3>
                    <div style="font-size:.75rem;color:var(--text-muted);">Rata-rata 7 hari terakhir</div>
                </div>
            </div>
            @if($avgScore !== null)
                <div style="font-size:3rem;font-weight:900;letter-spacing:-.05em;color:var(--text-dark);line-height:1;margin-bottom:6px;">{{ $avgScore }}</div>
                <p style="color:var(--text-muted);font-size:.8125rem;margin-bottom:16px;">Rata-rata skor ketergantungan</p>
                @if($changePercent !== null)
                    <div style="display:flex;align-items:center;gap:8px;padding:12px 14px;background:var(--bg-light);border-radius:var(--radius-lg);">
                        <span class="badge {{ $changePercent <= 0 ? 'badge-green' : 'badge-red' }}" style="padding:4px 10px;font-size:.7rem;">
                            @if($changePercent <= 0)
                                <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="18 15 12 9 6 15"/></svg>
                            @else
                                <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="6 9 12 15 18 9"/></svg>
                            @endif
                            {{ abs($changePercent) }}%
                        </span>
                        <span style="font-size:.8125rem;color:var(--text-muted);">{{ $changePercent <= 0 ? 'Membaik' : 'Meningkat' }} vs minggu lalu</span>
                    </div>
                @endif
            @else
                <div style="display:flex;flex-direction:column;align-items:center;padding:24px 0;gap:10px;">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="var(--text-muted)" stroke-width="1.5"><path d="M3 3v18h18"/><path d="M18.7 8l-5.1 5.2-2.8-2.7L7 14.3"/></svg>
                    <p style="color:var(--text-muted);font-size:.875rem;text-align:center;">Butuh lebih banyak data untuk insight</p>
                </div>
            @endif
        </div>
    </div>

    {{-- ── Kategori Dependensi — Upgraded Donut ── --}}
    <div class="anim-up d5 donut-card">
        <div class="card card-p" style="height:100%;">
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
                <div style="width:40px;height:40px;border-radius:var(--radius-md);background:rgba(13,148,136,.08);display:flex;align-items:center;justify-content:center;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--teal)" stroke-width="2.2"><path d="M21.21 15.89A10 10 0 1 1 8 2.83"/><path d="M22 12A10 10 0 0 0 12 2v10z"/></svg>
                </div>
                <div>
                    <h3 style="color:var(--text-dark);">Kategori Dependensi</h3>
                    <div style="font-size:.75rem;color:var(--text-muted);">Distribusi selama periode ini</div>
                </div>
            </div>

            <div style="display:flex;align-items:center;gap:20px;">
                {{-- Upgraded donut --}}
                <div class="donut-outer">
                    <svg viewBox="0 0 130 130">
                        <defs>
                            <filter id="donut-shadow">
                                <feDropShadow dx="0" dy="2" stdDeviation="3" flood-color="rgba(0,0,0,.15)"/>
                            </filter>
                            <linearGradient id="grad-rendah" x1="0%" y1="0%" x2="100%" y2="100%">
                                <stop offset="0%" stop-color="#22C55E"/>
                                <stop offset="100%" stop-color="#4ADE80"/>
                            </linearGradient>
                            <linearGradient id="grad-sedang" x1="0%" y1="0%" x2="100%" y2="100%">
                                <stop offset="0%" stop-color="#F59E0B"/>
                                <stop offset="100%" stop-color="#FCD34D"/>
                            </linearGradient>
                            <linearGradient id="grad-tinggi" x1="0%" y1="0%" x2="100%" y2="100%">
                                <stop offset="0%" stop-color="#EF4444"/>
                                <stop offset="100%" stop-color="#F87171"/>
                            </linearGradient>
                        </defs>
                        {{-- Track --}}
                        <circle cx="65" cy="65" r="{{ $r2 }}" fill="none" stroke="#E2E8F0" stroke-width="14"/>
                        {{-- Rendah --}}
                        <circle cx="65" cy="65" r="{{ $r2 }}" fill="none" stroke="url(#grad-rendah)" stroke-width="14"
                            stroke-linecap="round"
                            stroke-dasharray="{{ $rD }} {{ $circ2 - $rD }}"
                            stroke-dashoffset="0"
                            filter="url(#donut-shadow)"/>
                        {{-- Sedang --}}
                        <circle cx="65" cy="65" r="{{ $r2 }}" fill="none" stroke="url(#grad-sedang)" stroke-width="14"
                            stroke-linecap="round"
                            stroke-dasharray="{{ $sD }} {{ $circ2 - $sD }}"
                            stroke-dashoffset="{{ $sOff }}"
                            filter="url(#donut-shadow)"/>
                        {{-- Tinggi --}}
                        <circle cx="65" cy="65" r="{{ $r2 }}" fill="none" stroke="url(#grad-tinggi)" stroke-width="14"
                            stroke-linecap="round"
                            stroke-dasharray="{{ $tD }} {{ $circ2 - $tD }}"
                            stroke-dashoffset="{{ $tOff }}"
                            filter="url(#donut-shadow)"/>
                        {{-- Center white circle for depth --}}
                        <circle cx="65" cy="65" r="32" fill="white" opacity=".6"/>
                        <circle cx="65" cy="65" r="30" fill="white"/>
                    </svg>
                    <div class="donut-inner-text">
                        <div class="donut-inner-num">{{ $totalKuesioner }}</div>
                        <div class="donut-inner-lbl">kuesioner</div>
                    </div>
                </div>

                {{-- Legend with mini bars --}}
                <div style="flex:1;display:flex;flex-direction:column;gap:4px;">
                    <div class="cat-legend-row">
                        <div class="cat-dot-lg" style="background:var(--green);"></div>
                        <span style="font-size:.8125rem;color:var(--text-muted);flex:1;font-weight:500;">Rendah</span>
                        <div class="cat-bar-mini">
                            <div class="cat-bar-fill" style="width:{{ $catRendah }}%;background:var(--green);"></div>
                        </div>
                        <span style="font-size:.8125rem;font-weight:800;color:var(--text-dark);min-width:30px;text-align:right;">{{ $catRendah }}%</span>
                    </div>
                    <div style="margin-left:22px;margin-bottom:4px;">
                        <span class="badge badge-green" style="font-size:.68rem;padding:2px 8px;">{{ $catRendahCount }}x</span>
                    </div>

                    <div class="cat-legend-row">
                        <div class="cat-dot-lg" style="background:var(--amber);"></div>
                        <span style="font-size:.8125rem;color:var(--text-muted);flex:1;font-weight:500;">Sedang</span>
                        <div class="cat-bar-mini">
                            <div class="cat-bar-fill" style="width:{{ $catSedang }}%;background:var(--amber);"></div>
                        </div>
                        <span style="font-size:.8125rem;font-weight:800;color:var(--text-dark);min-width:30px;text-align:right;">{{ $catSedang }}%</span>
                    </div>
                    <div style="margin-left:22px;margin-bottom:4px;">
                        <span class="badge badge-amber" style="font-size:.68rem;padding:2px 8px;">{{ $catSedangCount }}x</span>
                    </div>

                    <div class="cat-legend-row">
                        <div class="cat-dot-lg" style="background:var(--red);"></div>
                        <span style="font-size:.8125rem;color:var(--text-muted);flex:1;font-weight:500;">Tinggi</span>
                        <div class="cat-bar-mini">
                            <div class="cat-bar-fill" style="width:{{ $catTinggi }}%;background:var(--red);"></div>
                        </div>
                        <span style="font-size:.8125rem;font-weight:800;color:var(--text-dark);min-width:30px;text-align:right;">{{ $catTinggi }}%</span>
                    </div>
                    <div style="margin-left:22px;">
                        <span class="badge badge-red" style="font-size:.68rem;padding:2px 8px;">{{ $catTinggiCount }}x</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- Habit Tracker --}}
    <div class="anim-up d6">
        <div class="card card-p" style="height:100%;">
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:6px;">
                <div style="width:40px;height:40px;border-radius:var(--radius-md);background:rgba(139,92,246,.08);display:flex;align-items:center;justify-content:center;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--purple)" stroke-width="2.2"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                </div>
                <div style="flex:1;">
                    <h3 style="color:var(--text-dark);">Habit Tracker</h3>
                    <div style="font-size:.75rem;color:var(--text-muted);">Hari ini</div>
                </div>
                <span class="badge badge-teal" style="font-size:.7rem;padding:3px 10px;">{{ $habitsDone }}/{{ $habitsTotal }}</span>
            </div>
            <div class="progress-bar" style="margin:12px 0 16px;">
                <div class="progress-fill" style="width:{{ ($habitsDone / $habitsTotal) * 100 }}%"></div>
            </div>
            <div style="display:flex;flex-direction:column;gap:8px;">
                @foreach($habits as $habit)
                <div class="habit-item" style="display:flex;align-items:center;gap:12px;padding:11px 14px;border-radius:var(--radius-lg);border:1px solid {{ $habit['done'] ? 'rgba(13,148,136,.2)' : 'var(--border-light)' }};background:{{ $habit['done'] ? 'rgba(13,148,136,.03)' : 'transparent' }};">
                    <div style="width:22px;height:22px;border-radius:50%;background:{{ $habit['done'] ? 'var(--teal)' : 'var(--bg-light)' }};border:2px solid {{ $habit['done'] ? 'var(--teal)' : 'var(--border-light)' }};display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                        @if($habit['done'])
                            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                        @endif
                    </div>
                    <span style="font-size:.875rem;font-weight:600;color:{{ $habit['done'] ? 'var(--text-muted)' : 'var(--text-muted)' }};">{{ $habit['label'] }}</span>
                </div>
                @endforeach
            </div>
        </div>
    </div>
</div>

{{-- ════ CTA Kuesioner ════ --}}
<div class="anim-up d4" style="margin-bottom:24px;">
    <a href="{{ url('/user/kuesioner') }}" class="card card-p" style="display:flex;align-items:center;gap:16px;border-color:rgba(13,148,136,.2);background:linear-gradient(135deg,rgba(13,148,136,.04),rgba(14,165,233,.04));transition:all .25s;">
        <div style="width:48px;height:48px;border-radius:var(--radius-lg);background:rgba(13,148,136,.1);display:flex;align-items:center;justify-content:center;flex-shrink:0;">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--teal)" stroke-width="2.2"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
        </div>
        <div style="flex:1;">
            <div style="font-weight:700;font-size:1rem;color:var(--text-dark);margin-bottom:2px;">Isi Kuesioner Hari Ini</div>
            <div style="font-size:.8125rem;color:var(--text-muted);">Pantau perkembangan ketergantungan digitalmu secara konsisten</div>
        </div>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--teal)" stroke-width="2.2"><polyline points="9 18 15 12 9 6"/></svg>
    </a>
</div>

{{-- ════ Tips + Quick Actions ════ --}}
<div class="dash-grid" style="margin-bottom:0;">
    <div class="anim-up d5">
        <div class="card card-p" style="height:100%;">
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
                <div style="width:40px;height:40px;border-radius:var(--radius-md);background:rgba(139,92,246,.08);display:flex;align-items:center;justify-content:center;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--purple)" stroke-width="2.2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                </div>
                <h3 style="color:var(--text-dark);">Tips Hari Ini</h3>
            </div>
            <div style="display:flex;flex-direction:column;gap:10px;">
                @foreach($tips as $tip)
                <div class="tip-row" style="display:flex;align-items:center;gap:12px;padding:14px 16px;background:var(--bg-light);border-radius:var(--radius-lg);">
                    <div style="width:32px;height:32px;border-radius:var(--radius-sm);background:{{ $tip['bg'] }};display:flex;align-items:center;justify-content:center;flex-shrink:0;color:{{ $tip['color'] }};">
                        {!! $tip['icon'] !!}
                    </div>
                    <span style="font-size:.875rem;font-weight:600;color:var(--text-dark);">{{ $tip['text'] }}</span>
                </div>
                @endforeach
            </div>
        </div>
    </div>

    <div class="anim-up d6">
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;height:100%;">
            <a href="{{ url('/user/histori') }}" class="card card-p" style="display:flex;align-items:center;gap:12px;">
                <div style="width:44px;height:44px;border-radius:var(--radius-md);background:rgba(13,148,136,.08);display:flex;align-items:center;justify-content:center;flex-shrink:0;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--teal)" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
                <div><div style="font-weight:700;color:var(--text-dark);">Histori</div><div style="font-size:.75rem;color:var(--text-muted);">Lihat riwayat</div></div>
            </a>
            <a href="{{ url('/user/grafik') }}" class="card card-p" style="display:flex;align-items:center;gap:12px;">
                <div style="width:44px;height:44px;border-radius:var(--radius-md);background:rgba(139,92,246,.08);display:flex;align-items:center;justify-content:center;flex-shrink:0;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--purple)" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg></div>
                <div><div style="font-weight:700;color:var(--text-dark);">Grafik</div><div style="font-size:.75rem;color:var(--text-muted);">Visualisasi data</div></div>
            </a>
            <a href="{{ url('/user/laporan') }}" class="card card-p" style="display:flex;align-items:center;gap:12px;">
                <div style="width:44px;height:44px;border-radius:var(--radius-md);background:rgba(59,130,246,.08);display:flex;align-items:center;justify-content:center;flex-shrink:0;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
                <div><div style="font-weight:700;color:var(--text-dark);">Laporan</div><div style="font-size:.75rem;color:var(--text-muted);">Perkembangan</div></div>
            </a>
            <a href="{{ url('/user/profil') }}" class="card card-p" style="display:flex;align-items:center;gap:12px;">
                <div style="width:44px;height:44px;border-radius:var(--radius-md);background:rgba(245,158,11,.08);display:flex;align-items:center;justify-content:center;flex-shrink:0;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--amber)" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
                <div><div style="font-weight:700;color:var(--text-dark);">Profil</div><div style="font-size:.75rem;color:var(--text-muted);">Pengaturan akun</div></div>
            </a>
        </div>
    </div>
</div>

@endsection

@section('scripts')
<script>

(function () {
    const ns = 'http://www.w3.org/2000/svg';
    const svg = document.createElementNS(ns, 'svg');
    svg.setAttribute('id', 'dash-bg-svg');
    svg.setAttribute('xmlns', ns);
    svg.setAttribute('preserveAspectRatio', 'xMidYMid slice');
 
    svg.innerHTML = `
    <defs>
        <!-- Radial fills for glow circles -->
        <radialGradient id="dbg-cg1" cx="50%" cy="50%" r="50%">
            <stop offset="20%" stop-color="#0D9488" stop-opacity="0"/>
            <stop offset="82%" stop-color="#0D9488" stop-opacity="0.12"/>
            <stop offset="100%" stop-color="#0D9488" stop-opacity="0"/>
        </radialGradient>
        <radialGradient id="dbg-cg2" cx="50%" cy="50%" r="50%">
            <stop offset="20%" stop-color="#0B1F6E" stop-opacity="0"/>
            <stop offset="82%" stop-color="#0B1F6E" stop-opacity="0.11"/>
            <stop offset="100%" stop-color="#0B1F6E" stop-opacity="0"/>
        </radialGradient>
        <radialGradient id="dbg-cg3" cx="50%" cy="50%" r="50%">
            <stop offset="20%" stop-color="#14B8A6" stop-opacity="0"/>
            <stop offset="82%" stop-color="#14B8A6" stop-opacity="0.09"/>
            <stop offset="100%" stop-color="#14B8A6" stop-opacity="0"/>
        </radialGradient>
        <radialGradient id="dbg-cg4" cx="50%" cy="50%" r="50%">
            <stop offset="20%" stop-color="#0F2860" stop-opacity="0"/>
            <stop offset="82%" stop-color="#0F2860" stop-opacity="0.10"/>
            <stop offset="100%" stop-color="#0F2860" stop-opacity="0"/>
        </radialGradient>
        <filter id="dbg-blur-sm">
            <feGaussianBlur stdDeviation="8"/>
        </filter>
        <filter id="dbg-blur-md">
            <feGaussianBlur stdDeviation="18"/>
        </filter>
        <filter id="dbg-blur-lg">
            <feGaussianBlur stdDeviation="32"/>
        </filter>
    </defs>
 
    <!-- ── Large rings (stroke only, di-glow via blur layer di bawahnya) ── -->
 
    <!-- Top-left teal ring cluster -->
    <circle cx="0" cy="5vh"   r="22vw" fill="none" stroke="#0D9488" stroke-width="1.2" opacity="0.13"/>
    <circle cx="0" cy="5vh"   r="22vw" fill="url(#dbg-cg1)" filter="url(#dbg-blur-md)" opacity="0.85"/>
    <circle cx="0" cy="5vh"   r="28vw" fill="none" stroke="#0D9488" stroke-width="0.5" opacity="0.08"/>
 
    <!-- Top-right navy ring cluster -->
    <circle cx="100vw" cy="2vh"   r="26vw" fill="none" stroke="#0B1F6E" stroke-width="1.1" opacity="0.12"/>
    <circle cx="100vw" cy="2vh"   r="26vw" fill="url(#dbg-cg2)" filter="url(#dbg-blur-md)" opacity="0.80"/>
    <circle cx="100vw" cy="2vh"   r="33vw" fill="none" stroke="#0B1F6E" stroke-width="0.4" opacity="0.06"/>
 
    <!-- Bottom-right teal ring cluster -->
    <circle cx="102vw" cy="100vh" r="30vw" fill="none" stroke="#14B8A6" stroke-width="1.0" opacity="0.11"/>
    <circle cx="102vw" cy="100vh" r="30vw" fill="url(#dbg-cg3)" filter="url(#dbg-blur-lg)" opacity="0.75"/>
 
    <!-- Center-left navy ring cluster -->
    <circle cx="8vw"  cy="62vh"  r="16vw" fill="none" stroke="#0F2860" stroke-width="1.0" opacity="0.12"/>
    <circle cx="8vw"  cy="62vh"  r="16vw" fill="url(#dbg-cg4)" filter="url(#dbg-blur-md)" opacity="0.80"/>
    <circle cx="8vw"  cy="62vh"  r="20vw" fill="none" stroke="#0F2860" stroke-width="0.4" opacity="0.07"/>
 
    <!-- Bottom-center wide thin ring -->
    <circle cx="50vw" cy="108vh" r="26vw" fill="none" stroke="#14B8A6" stroke-width="0.7" opacity="0.09"/>
 
    <!-- ── Medium accent rings ── -->
    <circle cx="82vw" cy="46vh" r="9vw"  fill="none" stroke="#0B2060" stroke-width="0.7" opacity="0.11"/>
    <circle cx="82vw" cy="46vh" r="11vw" fill="none" stroke="#0B2060" stroke-width="0.4" opacity="0.07"/>
    <circle cx="82vw" cy="46vh" r="9vw"  fill="#0B2060" fill-opacity="0.025" filter="url(#dbg-blur-sm)"/>
 
    <circle cx="22vw" cy="26vh" r="6vw"  fill="none" stroke="#0D9488" stroke-width="0.7" opacity="0.13"/>
    <circle cx="22vw" cy="26vh" r="8vw"  fill="none" stroke="#0D9488" stroke-width="0.4" opacity="0.08"/>
    <circle cx="22vw" cy="26vh" r="6vw"  fill="#0D9488" fill-opacity="0.03" filter="url(#dbg-blur-sm)"/>
 
    <circle cx="68vw" cy="86vh" r="7vw"  fill="none" stroke="#14B8A6" stroke-width="0.7" opacity="0.11"/>
    <circle cx="68vw" cy="86vh" r="9vw"  fill="none" stroke="#14B8A6" stroke-width="0.4" opacity="0.07"/>
    <circle cx="68vw" cy="86vh" r="7vw"  fill="#14B8A6" fill-opacity="0.025" filter="url(#dbg-blur-sm)"/>
 
    <!-- ── Small scattered glow dots ── -->
    <circle cx="57vw" cy="12vh" r="4"  fill="#0D9488" opacity="0.20"/>
    <circle cx="57vw" cy="12vh" r="10" fill="none" stroke="#0D9488" stroke-width="0.7" opacity="0.13"/>
    <circle cx="57vw" cy="12vh" r="5"  fill="#0D9488" opacity="0.10" filter="url(#dbg-blur-sm)"/>
 
    <circle cx="36vw" cy="81vh" r="3.5" fill="#0B2060" opacity="0.18"/>
    <circle cx="36vw" cy="81vh" r="9"   fill="none" stroke="#0B2060" stroke-width="0.6" opacity="0.12"/>
 
    <circle cx="84vw" cy="20vh" r="3.5" fill="#14B8A6" opacity="0.20"/>
    <circle cx="84vw" cy="20vh" r="9"   fill="none" stroke="#14B8A6" stroke-width="0.6" opacity="0.13"/>
    <circle cx="84vw" cy="20vh" r="4"   fill="#14B8A6" opacity="0.08" filter="url(#dbg-blur-sm)"/>
 
    <circle cx="14vw" cy="88vh" r="3"   fill="#0D9488" opacity="0.14"/>
    <circle cx="7vw"  cy="48vh" r="2.5" fill="#0B2060" opacity="0.13"/>
    <circle cx="91vw" cy="70vh" r="3"   fill="#0D9488" opacity="0.14"/>
    <circle cx="51vw" cy="53vh" r="2.5" fill="#14B8A6" opacity="0.10"/>
    <circle cx="73vw" cy="8vh"  r="3.5" fill="#0B2060" opacity="0.11"/>
    <circle cx="44vw" cy="96vh" r="2.5" fill="#0D9488" opacity="0.12"/>
    `;
 
    document.body.appendChild(svg);
})();

document.addEventListener('DOMContentLoaded', () => {
    // Animate horizontal score bar
    const hbar = document.getElementById('scoreHBar');
    if (hbar) {
        setTimeout(() => { hbar.style.width = '{{ $scoreBarPct }}%'; }, 100);
    }

    // Animate mini gauge
    const mg = document.getElementById('miniGaugeCircle');
    if (mg) {
        const target = mg.getAttribute('stroke-dashoffset');
        mg.style.strokeDashoffset = mg.getAttribute('stroke-dasharray');
        requestAnimationFrame(() => requestAnimationFrame(() => {
            mg.style.strokeDashoffset = target;
        }));
    }
});
</script>
@endsection