{{--
═══════════════════════════════════════════════
resources/views/admin/users.blade.php
═══════════════════════════════════════════════
--}}
@extends('layouts.app')
@section('title', 'User Management — Activa')
@section('page-title', 'User Management')

@section('topbar-actions')
  <span class="topbar-badge topbar-badge--navy">
    {{ number_format($total ?? 0) }} Users
  </span>
@endsection

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/users.css') }}">
@endpush

@section('content')

  {{-- STAT CARDS --}}
  <div class="stats-grid">
    <div class="stat-card">
      <div class="top-line top-line--navy"></div>
      <div class="stat-icon stat-icon--navy">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
          <circle cx="9" cy="7" r="4" />
          <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
          <path d="M16 3.13a4 4 0 0 1 0 7.75" />
        </svg>
      </div>
      <div class="stat-label">Total User</div>
      <div class="stat-val stat-val--navy">{{ number_format($stats['total'] ?? 0) }}</div>
      <div class="stat-change neu">Semua terdaftar</div>
    </div>

    <div class="stat-card">
      <div class="top-line top-line--amber"></div>
      <div class="stat-icon stat-icon--amber">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
          <circle cx="9" cy="7" r="4" />
          <line x1="19" y1="8" x2="19" y2="14" />
          <line x1="22" y1="11" x2="16" y2="11" />
        </svg>
      </div>
      <div class="stat-label">User Baru (7 Hari)</div>
      <div class="stat-val stat-val--amber">{{ number_format($stats['new_7d'] ?? 0) }}</div>
      <div class="stat-change up">↑ minggu ini</div>
    </div>
  </div>

  {{-- FILTER TOOLBAR — 1 baris --}}
  <form method="GET" action="{{ route('admin.users') }}" class="filter-bar">
    <div class="filter-bar__search">
      <span class="filter-bar__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="11" cy="11" r="8" />
          <line x1="21" y1="21" x2="16.65" y2="16.65" />
        </svg>
      </span>
      <input class="inp inp--search" name="search" placeholder="Cari nama atau email..." value="{{ request('search') }}">
    </div>

    <select class="inp" name="role" onchange="this.form.submit()">
      <option value="">Semua Role</option>
      <option value="student"   {{ request('role') === 'student'    ? 'selected' : '' }}>Student</option>
      <option value="worker"    {{ request('role') === 'worker'     ? 'selected' : '' }}>Worker</option>
      <option value="unemployed"{{ request('role') === 'unemployed' ? 'selected' : '' }}>Unemployed</option>
    </select>

    <select class="inp" name="gender" onchange="this.form.submit()">
      <option value="">Semua Gender</option>
      <option value="perempuan" {{ request('gender') === 'perempuan' ? 'selected' : '' }}>Perempuan</option>
      <option value="laki-laki" {{ request('gender') === 'laki-laki' ? 'selected' : '' }}>Laki-laki</option>
    </select>

    <select class="inp" name="sort" onchange="this.form.submit()">
      <option value="latest" {{ request('sort') === 'latest' ? 'selected' : '' }}>Terbaru</option>
      <option value="oldest" {{ request('sort') === 'oldest' ? 'selected' : '' }}>Terlama</option>
    </select>

    <button type="submit" class="btn btn-navy btn-sm">Cari</button>

    @if(request()->hasAny(['search', 'role', 'gender', 'sort']))
      <a href="{{ route('admin.users') }}" class="btn btn-ghost btn-sm">Reset</a>
    @endif
  </form>

  {{-- TABLE --}}
  <div class="card">
    <div class="card-header">
      <div>
        <div class="card-title">Daftar Pengguna</div>
        <div class="card-sub">Menampilkan {{ $users->count() }} dari {{ number_format($users->total()) }} pengguna</div>
      </div>
    </div>
    <div class="tbl-wrap">
      <table>
        <thead>
          <tr>
            <th>No</th>
            <th>Nama</th>
            <th>Email</th>
            <th>Gender</th>
            <th>Umur</th>
            <th>Daerah Asal</th>
            <th>Pendidikan</th>
            <th>Peran Harian</th>
            <th>Total Isi Kuesioner</th>
            <th>Aksi</th>
          </tr>
        </thead>
        <tbody>
          @forelse($users as $index => $user)
            <tr>
              <td class="cell--muted">{{ $users->firstItem() + $index }}</td>
              <td>
                <div class="user-cell">
                  <div class="avatar avatar--teal">{{ strtoupper(substr($user->name, 0, 2)) }}</div>
                  <div class="user-cell__name">{{ $user->name }}</div>
                </div>
              </td>
              <td class="cell--muted cell--sm">{{ $user->email }}</td>
              <td class="cell--body">{{ $user->gender ?? '-' }}</td>
              <td class="cell--body">{{ $user->age ?? '-' }}</td>
              <td class="cell--body">{{ $user->region ?? '-' }}</td>
              <td class="cell--body">{{ $user->education_level ?? '-' }}</td>
              <td class="cell--body">{{ $user->daily_role ?? '-' }}</td>
              <td class="cell--body">{{ $user->questionnaire_count ?? 0 }}</td>
              <td>
                <form method="POST" action="{{ route('admin.users.destroy', $user->id) }}"
                  data-name="{{ htmlspecialchars($user->name, ENT_QUOTES, 'UTF-8') }}"
                  onsubmit="return confirm('Hapus ' + this.dataset.name + '?')">
                  @csrf @method('DELETE')
                  <button type="submit" class="btn btn-danger btn-sm">Hapus</button>
                </form>
              </td>
            </tr>
          @empty
            <tr>
              <td colspan="10" class="tbl-empty">Tidak ada data pengguna</td>
            </tr>
          @endforelse
        </tbody>
      </table>
    </div>
    @if(isset($users) && method_exists($users, 'links'))
      <div class="tbl-pagination">
        {{ $users->links() }}
      </div>
    @endif
  </div>

  {{-- Route bridge for JS --}}
  <div id="route-data" data-destroy-base="/admin/users" data-csrf="{{ csrf_token() }}" hidden></div>

@endsection

@push('scripts')
  <script src="{{ asset('js/users.js') }}"></script>
@endpush