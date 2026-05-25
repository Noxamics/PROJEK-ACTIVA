@extends('web.layouts.app')
@section('title', 'Histori')

@section('styles')
@section('body-class', 'page-histori')
<link href="{{ asset('css/user-web/histori.css') }}" rel="stylesheet">
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

{{-- ── Page Header ── --}}
<div class="hist-header anim-fade">
    <h1>Histori Kuesioner</h1>
    <p>Riwayat semua analisis yang pernah kamu lakukan</p>
</div>

{{-- ── Toolbar: count + sort ── --}}
<div class="hist-toolbar anim-up d1">
    <div class="hist-count">{{ $surveys->count() }} hasil ditemukan</div>
    <div class="sort-chips">
        @foreach(['terbaru','terlama','tertinggi','terendah'] as $s)
            <a href="{{ url('/user/histori?sort='.$s) }}"
               class="sort-chip {{ $sort === $s ? 'active' : '' }}">
                {{ ucfirst($s) }}
            </a>
        @endforeach
    </div>
</div>

{{-- ── Empty State ── --}}
@if($surveys->isEmpty())
<div class="card hist-empty anim-up d2">
    <div class="empty-icon">📋</div>
    <h3>Belum Ada Histori</h3>
    <p>Isi kuesioner pertamamu untuk mulai tracking.</p>
    <a href="{{ url('/user/kuesioner') }}" class="btn btn-primary">Mulai Kuesioner</a>
</div>

{{-- ── Timeline ── --}}
@else
<div class="hist-timeline">

    @php
        $grouped = $surveys->groupBy(fn($s) => $s->created_at
            ? strtoupper($s->created_at->translatedFormat('F Y'))
            : 'TIDAK DIKETAHUI');

        // Dummy AI opening phrases per category
        $aiOpenings = [
            'Rendah' => 'Aktivitas digitalmu terkendali dengan baik. Pertahankan keseimbangan ini dan terus jaga pola hidup sehatmu. 🌿',
            'Sedang' => 'Screen time malam hari masih cukup tinggi. Coba jadwalkan waktu offline untuk menjaga keseimbangan digital.',
            'Tinggi' => 'Perlu perhatian ekstra. Tidur & istirahat digitalmu butuh penyesuaian segera untuk kesehatan jangka panjang. 💙',
        ];

        // Dummy recommendations per category
        $dummyRecs = [
            'Rendah' => [
                'Pertahankan jadwal screen time',
                'Lanjutkan aktivitas fisik rutin',
                'Tetap batasi media sosial malam',
            ],
            'Sedang' => [
                'Batasi screen time setelah jam 21.00',
                'Jadwalkan waktu offline harian',
                'Kurangi notifikasi tidak penting',
            ],
            'Tinggi' => [
                'Perlu perhatian ekstra segera',
                'Tidur & istirahat lebih awal',
                'Batasi media sosial secara ketat',
                'Konsultasi digital wellness',
            ],
        ];

        $statusText = [
            'Rendah' => 'Terkendali',
            'Sedang' => 'Mulai Stabil',
            'Tinggi' => 'Perlu Perhatian',
        ];

        $dotClass  = ['Rendah' => 'dot-low',  'Sedang' => 'dot-medium',  'Tinggi' => 'dot-high'];
        $ringClass = ['Rendah' => 'ring-low', 'Sedang' => 'ring-medium', 'Tinggi' => 'ring-high'];
        $catClass  = ['Rendah' => 'cat-low',  'Sedang' => 'cat-medium',  'Tinggi' => 'cat-high'];
        $cardClass = ['Rendah' => 'card-low', 'Sedang' => 'card-medium', 'Tinggi' => 'card-high'];

        $delay = 2;
        $circum = 188.5; // SVG ring circumference (r=30)
    @endphp

    @foreach($grouped as $monthLabel => $items)

        {{-- ── Month label bar ── --}}
        <div class="hist-month-label">{{ $monthLabel }}</div>

        @foreach($items as $item)
        @php
            $score   = $item->score ?? 0;
            $cat     = $score < 33.47 ? 'Rendah' : ($score <= 61.34 ? 'Sedang' : 'Tinggi');
            $rounded = round($score);
            $offset  = $circum - ($circum * $rounded / 100);
            $delay   = min($delay, 8);
        @endphp

        <div class="hist-row anim-up d{{ $delay }}">

            {{-- Timeline dot --}}
            <div class="hist-dot-col">
                <div class="hist-dot {{ $dotClass[$cat] ?? 'dot-medium' }}"></div>
            </div>

            {{-- Card --}}
            <div class="hist-card-wrap">
                <a href="{{ url('/user/hasil/'.$item->_id) }}" class="hist-card-link">
                    <div class="hist-card {{ $cardClass[$cat] ?? 'card-medium' }}">

                        {{-- ① Score ring + badges --}}
                        <div class="hist-score-col">
                            <div class="score-ring-wrap {{ $ringClass[$cat] ?? 'ring-medium' }}">
                                {{-- glow blob behind ring --}}
                                <div class="score-ring-glow"></div>
                                <svg width="72" height="72" viewBox="0 0 72 72">
                                    <circle class="score-ring-bg"
                                        cx="36" cy="36" r="30"/>
                                    <circle class="score-ring-fill {{ $ringClass[$cat] ?? 'ring-medium' }}"
                                        cx="36" cy="36" r="30"
                                        stroke-dasharray="{{ $circum }}"
                                        stroke-dashoffset="{{ $offset }}"/>
                                </svg>
                                <div class="score-ring-number">{{ $rounded }}</div>
                            </div>
                            <div class="hist-badges">
                                <span class="badge-cat {{ $catClass[$cat] ?? 'cat-medium' }}">{{ $cat }}</span>
                                <span class="badge-status">{{ $statusText[$cat] ?? '-' }}</span>
                            </div>
                        </div>

                        {{-- ② Info + AI opening --}}
                        <div class="hist-info-col">
                            <div class="hist-card-title">Analisis — Skor {{ $rounded }}/100</div>
                            <div class="hist-card-date">
                                {{ $item->created_at ? $item->created_at->format('d M Y, H:i') : '-' }}
                            </div>
                            <div class="hist-divider"></div>
                            <div class="hist-ai-opening">
                                <div class="ai-icon">
                                    <svg viewBox="0 0 10 10" fill="none" stroke="#fff" stroke-width="1.8" stroke-linecap="round">
                                        <path d="M2 5h6M5 2l3 3-3 3"/>
                                    </svg>
                                </div>
                                <span>{{ $aiOpenings[$cat] ?? '' }}</span>
                            </div>
                        </div>

                        {{-- ③ Recommendations panel --}}
                        <div class="hist-rec-col">
                            <div class="hist-rec-title">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                                </svg>
                                Saran Tindakan
                            </div>
                            <ul class="hist-rec-list">
                                @foreach($dummyRecs[$cat] ?? [] as $rec)
                                    <li>{{ $rec }}</li>
                                @endforeach
                            </ul>
                        </div>

                        {{-- Mobile arrow --}}
                        <div class="hist-arrow">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                                 stroke="rgba(255,255,255,.3)" stroke-width="2">
                                <polyline points="9 18 15 12 9 6"/>
                            </svg>
                        </div>

                    </div>{{-- .hist-card --}}
                </a>
            </div>{{-- .hist-card-wrap --}}

        </div>{{-- .hist-row --}}
        @php $delay++; @endphp
        @endforeach

    @endforeach

</div>{{-- .hist-timeline --}}
@endif

@endsection