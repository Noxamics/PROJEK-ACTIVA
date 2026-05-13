@extends('web.layouts.app')
@section('title', 'Histori')

@section('content')
<div class="page-header anim-fade"><h1>Histori Kuesioner</h1><p>Riwayat semua analisis yang pernah kamu lakukan</p></div>

<div class="anim-up d1" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:24px;flex-wrap:wrap;gap:12px;">
    <div style="font-size:.9375rem;color:var(--text-muted);font-weight:600;">{{ $surveys->count() }} hasil ditemukan</div>
    <div class="filter-chips">
        @foreach(['terbaru','terlama','tertinggi','terendah'] as $s)
        <a href="{{ url('/user/histori?sort='.$s) }}" class="filter-chip {{ $sort===$s ? 'active' : '' }}">{{ ucfirst($s) }}</a>
        @endforeach
    </div>
</div>

@if($surveys->isEmpty())
<div class="card card-p-lg anim-up" style="text-align:center;">
    <div style="font-size:3rem;margin-bottom:12px;">📋</div>
    <h3>Belum Ada Histori</h3>
    <p style="color:var(--text-muted);margin:8px 0 20px;">Isi kuesioner pertamamu untuk mulai tracking.</p>
    <a href="{{ url('/user/kuesioner') }}" class="btn btn-primary">Mulai Kuesioner</a>
</div>
@else
<div style="display:flex;flex-direction:column;gap:12px;">
    @foreach($surveys as $i => $item)
    @php
        $score = $item->score ?? 0;
        $scoreBg = $score < 33.47 ? 'linear-gradient(135deg,#22C55E,#16A34A)' : ($score <= 61.34 ? 'linear-gradient(135deg,#F59E0B,#D97706)' : 'linear-gradient(135deg,#EF4444,#DC2626)');
        $scoreCat = $score < 33.47 ? 'Rendah' : ($score <= 61.34 ? 'Sedang' : 'Tinggi');
    @endphp
    <a href="{{ url('/user/hasil/'.$item->_id) }}" class="hist-card anim-up d{{ min($i+1,6) }}">
        <div class="hist-score" style="background:{{ $scoreBg }};">{{ round($score) }}</div>
        <div style="flex:1;">
            <div style="font-weight:700;font-size:.9375rem;">{{ $scoreCat }} — Skor {{ round($score) }}/100</div>
            <div style="font-size:.8125rem;color:var(--text-muted);margin-top:4px;">{{ $item->created_at ? $item->created_at->format('d M Y, H:i') : '-' }}</div>
        </div>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--text-disabled)" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
    </a>
    @endforeach
</div>
@endif
@endsection
