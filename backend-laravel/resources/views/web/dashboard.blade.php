@extends('web.layouts.app')
@section('title', 'Dashboard')

@section('content')
@php
    $hour = (int)date('H');
    $greeting = $hour < 11 ? '🌅 Selamat Pagi' : ($hour < 15 ? '☀️ Selamat Siang' : ($hour < 18 ? '🌇 Selamat Sore' : '🌙 Selamat Malam'));

    $score = $latestMl ? ($latestMl->ml_result['digital_dependence_score'] ?? 0) : null;
    $confRaw = $latestMl ? ($latestMl->ml_result['confidence'] ?? 0) : null;
    $confidence = is_array($confRaw) ? ($confRaw['confidence_final_pct'] ?? 0) : (is_numeric($confRaw) ? (float)$confRaw : null);
    $ai = $latestMl ? ($latestMl->ai_analysis ?? []) : [];
    $scoreColor = $score !== null ? ($score < 33.47 ? 'var(--green)' : ($score <= 61.34 ? 'var(--amber)' : 'var(--red)')) : '#64748B';
    $scoreCat = $score !== null ? ($score < 33.47 ? 'Rendah' : ($score <= 61.34 ? 'Sedang' : 'Tinggi')) : '-';
    $scoreBadge = $score !== null ? ($score < 33.47 ? 'green' : ($score <= 61.34 ? 'amber' : 'red')) : 'blue';
    $circumference = 2 * 3.14159 * 85;
    $offset = $score !== null ? $circumference - ($score / 100) * $circumference : $circumference;
@endphp

<div class="page-header anim-fade">
    <h1>{{ $greeting }}, {{ explode(' ', $user->name)[0] }}!</h1>
    <p>Pantau gaya hidup digitalmu hari ini</p>
</div>

<div class="dash-grid">
    {{-- Score Card --}}
    <div class="card card-p-lg full anim-up" style="background:linear-gradient(135deg,var(--bg-dark),var(--bg-card));border:1px solid var(--border-card);">
        <div style="display:flex;align-items:center;gap:40px;flex-wrap:wrap;">
            <div style="flex-shrink:0;">
                <div class="score-gauge" style="width:200px;height:200px;">
                    <svg viewBox="0 0 200 200">
                        <circle cx="100" cy="100" r="85" fill="none" stroke="{{ $scoreColor }}15" stroke-width="12"/>
                        @if($score !== null)
                        <circle cx="100" cy="100" r="85" fill="none" stroke="{{ $scoreColor }}" stroke-width="12" stroke-linecap="round"
                            stroke-dasharray="{{ $circumference }}" stroke-dashoffset="{{ $offset }}" style="transition:stroke-dashoffset 1.5s cubic-bezier(.16,1,.3,1)"/>
                        @endif
                    </svg>
                    <div class="score-gauge-text">
                        @if($score !== null)
                            <div class="score-value" @style="color: {{ $scoreColor }}">{{ round($score) }}</div>
                            <div class="score-label" style="color:var(--text-secondary);">dari 100</div>
                        @else
                            <div style="font-size:2.5rem;">🔒</div>
                            <div class="score-label" style="color:var(--text-secondary);">Belum ada data</div>
                        @endif
                    </div>
                </div>
            </div>
            <div style="flex:1;min-width:240px;">
                <h2 style="color:var(--text-primary);margin-bottom:10px;">Skor Ketergantungan Digital</h2>
                @if($score !== null)
                    <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px;">
                        <span class="badge badge-{{ $scoreBadge }}">{{ $scoreCat }}</span>
                        @if($confidence)<span style="color:var(--text-secondary);font-size:.8125rem;">Confidence: {{ round($confidence) }}%</span>@endif
                    </div>
                    <p style="color:var(--text-secondary);font-size:.9375rem;line-height:1.8;margin-bottom:20px;">
                        {{ $ai['pembukaan'] ?? $ai['summary'] ?? 'Skor ini menunjukkan tingkat ketergantungan digitalmu saat ini.' }}
                    </p>
                    <a href="{{ url('/user/kuesioner') }}" class="btn btn-primary btn-sm">Isi Kuesioner Baru</a>
                @else
                    <p style="color:var(--text-secondary);margin-bottom:20px;">Isi kuesioner pertamamu untuk mendapatkan skor analisis berbasis Machine Learning.</p>
                    <a href="{{ url('/user/kuesioner') }}" class="btn btn-primary">🚀 Mulai Kuesioner</a>
                @endif
            </div>
        </div>
    </div>

    {{-- Insight --}}
    <div class="card card-p anim-up d2">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px;">
            <div style="width:40px;height:40px;border-radius:var(--radius-lg);background:rgba(59,130,246,.06);display:flex;align-items:center;justify-content:center;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
            </div>
            <h3>Insight Mingguan</h3>
        </div>
        @if($avgScore !== null)
            <div style="font-size:2.5rem;font-weight:900;color:var(--text-dark);margin-bottom:4px;">{{ $avgScore }}</div>
            <p style="color:var(--text-muted);font-size:.8125rem;">Rata-rata skor 7 hari terakhir</p>
            @if($changePercent !== null)
                <div style="margin-top:14px;display:flex;align-items:center;gap:8px;">
                    <span class="badge badge-{{ $changePercent <= 0 ? 'green' : 'red' }}">{{ $changePercent <= 0 ? '↓' : '↑' }} {{ abs($changePercent) }}%</span>
                    <span style="font-size:.8125rem;color:var(--text-muted);">{{ $changePercent <= 0 ? 'Membaik' : 'Memburuk' }}</span>
                </div>
            @endif
        @else
            <div style="padding:16px 0;color:var(--text-muted);font-size:.9375rem;">
                <span style="font-size:2rem;">📊</span><br><br>
                Butuh lebih banyak data untuk insight
            </div>
        @endif
    </div>

    {{-- Tips --}}
    <div class="card card-p anim-up d3">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px;">
            <div style="width:40px;height:40px;border-radius:var(--radius-lg);background:rgba(139,92,246,.06);display:flex;align-items:center;justify-content:center;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--purple)" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
            </div>
            <h3>Tips Hari Ini</h3>
        </div>
        <div style="display:flex;flex-direction:column;gap:10px;">
            <div style="padding:14px 16px;background:var(--bg-light);border-radius:var(--radius-lg);font-size:.875rem;color:var(--text-dark);font-weight:500;">💡 Coba matikan notifikasi non-esensial selama 2 jam</div>
            <div style="padding:14px 16px;background:var(--bg-light);border-radius:var(--radius-lg);font-size:.875rem;color:var(--text-dark);font-weight:500;">🌿 Luangkan 15 menit untuk jalan kaki tanpa HP</div>
            <div style="padding:14px 16px;background:var(--bg-light);border-radius:var(--radius-lg);font-size:.875rem;color:var(--text-dark);font-weight:500;">😴 Hindari layar 30 menit sebelum tidur</div>
        </div>
    </div>

    {{-- Quick Actions --}}
    <div class="full anim-up d4" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px;">
        <a href="{{ url('/user/histori') }}" class="card card-p" style="display:flex;align-items:center;gap:14px;">
            <div style="width:44px;height:44px;border-radius:var(--radius-lg);background:rgba(13,148,136,.06);display:flex;align-items:center;justify-content:center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--teal)" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
            <div><div style="font-weight:700;">Histori</div><div style="font-size:.8125rem;color:var(--text-muted);">Lihat riwayat</div></div>
        </a>
        <a href="{{ url('/user/grafik') }}" class="card card-p" style="display:flex;align-items:center;gap:14px;">
            <div style="width:44px;height:44px;border-radius:var(--radius-lg);background:rgba(139,92,246,.06);display:flex;align-items:center;justify-content:center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--purple)" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg></div>
            <div><div style="font-weight:700;">Grafik</div><div style="font-size:.8125rem;color:var(--text-muted);">Visualisasi data</div></div>
        </a>
        <a href="{{ url('/user/laporan') }}" class="card card-p" style="display:flex;align-items:center;gap:14px;">
            <div style="width:44px;height:44px;border-radius:var(--radius-lg);background:rgba(59,130,246,.06);display:flex;align-items:center;justify-content:center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
            <div><div style="font-weight:700;">Laporan</div><div style="font-size:.8125rem;color:var(--text-muted);">Perkembangan</div></div>
        </a>
    </div>
</div>
@endsection