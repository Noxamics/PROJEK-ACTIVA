{{--
═══════════════════════════════════════════════
resources/views/admin/monitoring.blade.php
═══════════════════════════════════════════════
--}}
@extends('layouts.app')
@section('title', 'Monitoring ML — Activa')
@section('page-title', 'Monitoring ML')

@section('topbar-actions')
  <span class="pill pill-teal">
    <svg width="7" height="7" viewBox="0 0 7 7" fill="none">
      <circle cx="3.5" cy="3.5" r="3.5" fill="currentColor" opacity="0.9" />
    </svg>
    Model v2.1 Aktif
  </span>
@endsection

@push('head-scripts')
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/monitoring.css') }}">
@endpush

@section('content')

  {{-- STAT CARDS --}}
  <div class="stats-grid">

    {{-- Focus Score --}}
    <div class="stat-card">
      <div class="top-line top-line--teal"></div>
      <div class="stat-icon stat-icon--teal">
        {{-- Target / Crosshair icon --}}
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"
          stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10" />
          <circle cx="12" cy="12" r="6" />
          <circle cx="12" cy="12" r="2" />
        </svg>
      </div>
      <div class="stat-label">Avg. Focus Score</div>
      <div class="stat-val stat-val--teal">{{ $metrics['avg_focus'] ?? 0 }}</div>
      <div class="stat-change up">
        <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"
          stroke-linecap="round" stroke-linejoin="round">
          <polyline points="18 15 12 9 6 15" />
        </svg>
        3.2 dari bulan lalu
      </div>
    </div>

    {{-- Productivity --}}
    <div class="stat-card">
      <div class="top-line top-line--navy"></div>
      <div class="stat-icon stat-icon--navy">
        {{-- Zap / Lightning icon --}}
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"
          stroke-linecap="round" stroke-linejoin="round">
          <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />
        </svg>
      </div>
      <div class="stat-label">Avg. Productivity</div>
      <div class="stat-val stat-val--navy">{{ $metrics['avg_productivity'] ?? 0 }}</div>
      <div class="stat-change up">
        <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"
          stroke-linecap="round" stroke-linejoin="round">
          <polyline points="18 15 12 9 6 15" />
        </svg>
        1.8 dari bulan lalu
      </div>
    </div>

    {{-- Digital Dependence --}}
    <div class="stat-card">
      <div class="top-line top-line--violet"></div>
      <div class="stat-icon stat-icon--violet">
        {{-- Link / Chain icon --}}
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"
          stroke-linecap="round" stroke-linejoin="round">
          <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" />
          <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" />
        </svg>
      </div>
      <div class="stat-label">Avg. Digital Dep.</div>
      <div class="stat-val stat-val--violet">{{ $metrics['avg_dependence'] ?? 0 }}</div>
      <div class="stat-change up">
        <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"
          stroke-linecap="round" stroke-linejoin="round">
          <polyline points="6 9 12 15 18 9" />
        </svg>
        2.1 dari bulan lalu
      </div>
    </div>

    {{-- Screen Time --}}
    <div class="stat-card">
      <div class="top-line top-line--amber"></div>
      <div class="stat-icon stat-icon--amber">
        {{-- Smartphone icon --}}
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"
          stroke-linecap="round" stroke-linejoin="round">
          <rect x="5" y="2" width="14" height="20" rx="2" ry="2" />
          <line x1="12" y1="18" x2="12.01" y2="18" />
        </svg>
      </div>
      <div class="stat-label">Avg. Screen Time</div>
      <div class="stat-val stat-val--amber">
        {{ $metrics['avg_screen'] ?? 0 }}<span class="stat-val__unit"> jam</span>
      </div>
      <div class="stat-change down">
        <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"
          stroke-linecap="round" stroke-linejoin="round">
          <polyline points="18 15 12 9 6 15" />
        </svg>
        0.3j dari bulan lalu
      </div>
    </div>

  </div>

  {{-- CHARTS ROW 1 --}}
  <div class="grid-2 mb-4">

    <div class="card">
      <div class="card-header">
        <div class="card-header__icon card-header__icon--teal">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
            stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="20" x2="18" y2="10" />
            <line x1="12" y1="20" x2="12" y2="4" />
            <line x1="6" y1="20" x2="6" y2="14" />
          </svg>
        </div>
        <div>
          <div class="card-title">Distribusi Screen Time</div>
          <div class="card-sub">Jumlah user per rentang jam/hari</div>
        </div>
      </div>
      <canvas id="c1"></canvas>
    </div>

    <div class="card">
      <div class="card-header">
        <div class="card-header__icon card-header__icon--violet">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
            stroke-linecap="round" stroke-linejoin="round">
            <polygon
              points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
          </svg>
        </div>
        <div>
          <div class="card-title">Profil: Low vs High Risk</div>
          <div class="card-sub">Perbandingan 6 dimensi wellness</div>
        </div>
      </div>
      <canvas id="c2"></canvas>
    </div>

  </div>

  {{-- TREND CHART --}}
  <div class="card mb-4">
    <div class="card-header">
      <div class="card-header__left">
        <div class="card-header__icon card-header__icon--navy">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
            stroke-linecap="round" stroke-linejoin="round">
            <polyline points="22 12 18 12 15 21 9 3 6 12 2 12" />
          </svg>
        </div>
        <div>
          <div class="card-title">Tren Bulanan Semua Metrik</div>
          <div class="card-sub">6 bulan terakhir</div>
        </div>
      </div>
      <span class="pill pill-navy">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
          stroke-linecap="round" stroke-linejoin="round">
          <path d="M12 2L2 7l10 5 10-5-10-5z" />
          <path d="M2 17l10 5 10-5" />
          <path d="M2 12l10 5 10-5" />
        </svg>
        {{ $modelAccuracy ?? 87 }}% Akurasi Model
      </span>
    </div>
    <canvas id="c3"></canvas>
  </div>

  {{-- BOTTOM GRID --}}
  <div class="grid-2">

    {{-- TOP FOCUS --}}
    <div class="card">
      <div class="card-header">
        <div class="card-header__left">
          <div class="card-header__icon card-header__icon--teal">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
              stroke-linecap="round" stroke-linejoin="round">
              <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
              <circle cx="9" cy="7" r="4" />
              <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
              <path d="M16 3.13a4 4 0 0 1 0 7.75" />
            </svg>
          </div>
          <div>
            <div class="card-title">Top Focus Score</div>
            <div class="card-sub">5 user dengan skor terbaik</div>
          </div>
        </div>
        <a href="/users" class="card-action">
          Lihat semua
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"
            stroke-linecap="round" stroke-linejoin="round">
            <polyline points="9 18 15 12 9 6" />
          </svg>
        </a>
      </div>
      <div class="user-list">
        @foreach($topUsers ?? [] as $i => $u)
          <div class="user-row {{ !$loop->last ? 'user-row--border' : '' }}">
            <div class="user-row__rank">#{{ $i + 1 }}</div>
            <div class="avatar avatar--teal">{{ strtoupper(substr($u['name'], 0, 2)) }}</div>
            <div class="user-row__info">
              <div class="user-row__name">{{ $u['name'] }}</div>
              <div class="score-bar">
                <div class="score-bar__fill score-bar__fill--teal" data-width="{{ $u['focus_score'] }}"></div>
              </div>
            </div>
            <div class="user-row__score score--teal">{{ $u['focus_score'] }}</div>
          </div>
        @endforeach
      </div>
    </div>

    {{-- HIGH RISK --}}
    <div class="card">
      <div class="card-header">
        <div class="card-header__left">
          <div class="card-header__icon card-header__icon--red">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
              stroke-linecap="round" stroke-linejoin="round">
              <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
              <line x1="12" y1="9" x2="12" y2="13" />
              <line x1="12" y1="17" x2="12.01" y2="17" />
            </svg>
          </div>
          <div>
            <div class="card-title">Perlu Perhatian</div>
            <div class="card-sub">Digital dependence tertinggi</div>
          </div>
        </div>
        <a href="/users?risk=high" class="card-action card-action--red">
          Kelola
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"
            stroke-linecap="round" stroke-linejoin="round">
            <polyline points="9 18 15 12 9 6" />
          </svg>
        </a>
      </div>
      <div class="user-list">
        @foreach($riskUsers ?? [] as $i => $u)
          @php $isHighRisk = $u['digital_dep'] > 66; @endphp
          <div class="user-row {{ !$loop->last ? 'user-row--border' : '' }}">
            <div class="user-row__rank">#{{ $i + 1 }}</div>
            <div class="avatar {{ $isHighRisk ? 'avatar--red' : 'avatar--amber' }}">
              {{ strtoupper(substr($u['name'], 0, 2)) }}
            </div>
            <div class="user-row__info">
              <div class="user-row__name">{{ $u['name'] }}</div>
              <div class="score-bar">
                <div class="score-bar__fill {{ $isHighRisk ? 'score-bar__fill--red' : 'score-bar__fill--amber' }}"
                  data-width="{{ $u['digital_dep'] }}"></div>
              </div>
            </div>
            <div class="user-row__score {{ $isHighRisk ? 'score--red' : 'score--amber' }}">
              {{ $u['digital_dep'] }}
            </div>
          </div>
        @endforeach
      </div>
    </div>

  </div>

  {{-- Data bridge for JS --}}
  <div id="chart-data"
    data-screen-dist="{{ json_encode($screenDistribution ?? ['labels' => [], 'data' => [], 'colors' => []]) }}"
    data-radar="{{ json_encode($radarData ?? []) }}"
    data-trend="{{ json_encode($monthlyTrend ?? ['labels' => [], 'focus' => [], 'productivity' => [], 'dependence' => []]) }}"
    hidden></div>

@endsection

@push('scripts')
  <script src="{{ asset('js/monitoring.js') }}"></script>
@endpush