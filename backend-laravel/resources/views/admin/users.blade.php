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
  <style>
    /* ══════════════════════════════════════
       GLOBAL SEARCH BAR — Premium Design
       ══════════════════════════════════════ */
    .global-search {
      display: flex; align-items: center; gap: 14px;
      padding: 16px 22px; margin-top: 10px;
      background: var(--white); border: 1px solid var(--border);
      border-radius: var(--radius-lg); box-shadow: var(--shadow);
      animation: fadeUp .35s ease both;
    }
    .global-search__icon {
      width: 40px; height: 40px; border-radius: 12px;
      background: linear-gradient(135deg, var(--teal), #34d399);
      display: flex; align-items: center; justify-content: center;
      color: #fff; flex-shrink: 0;
      box-shadow: 0 4px 12px rgba(13,148,136,.25);
    }
    .global-search__icon svg { width: 18px; height: 18px; }
    .global-search__wrap { flex: 1; position: relative; }
    .global-search__input {
      width: 100%; padding: 11px 16px 11px 40px;
      border: 1.5px solid #E2E8F0; border-radius: 12px;
      font-size: 14px; font-weight: 500; color: var(--navy);
      background: #FAFCFF; outline: none; font-family: var(--sans);
      transition: all .3s cubic-bezier(.4,0,.2,1);
    }
    .global-search__input:focus {
      border-color: var(--teal); background: #fff;
      box-shadow: 0 0 0 4px rgba(13,148,136,.1), 0 2px 8px rgba(15,31,53,.06);
    }
    .global-search__input::placeholder { color: #94A3B8; font-weight: 400; }
    .global-search__search-icon {
      position: absolute; left: 13px; top: 50%; transform: translateY(-50%);
      color: #94A3B8; pointer-events: none; display: flex;
    }
    .global-search__search-icon svg { width: 16px; height: 16px; }
    .global-search__info {
      font-size: 12px; color: var(--text3); font-weight: 500;
      white-space: nowrap; display: flex; align-items: center; gap: 6px;
    }
    .global-search__info span { color: var(--teal); font-weight: 700; }
    .global-search__clear {
      padding: 6px 14px; border: 1.5px solid #E2E8F0; border-radius: 9px;
      background: #fff; font-size: 12px; font-weight: 600; color: var(--text2);
      cursor: pointer; transition: all .2s; white-space: nowrap;
    }
    .global-search__clear:hover { border-color: var(--red); color: var(--red); background: var(--red-lt); }

    /* ══════════════════════════════════════
       TABLE WRAP & CONTAINER
       ══════════════════════════════════════ */
    .table-wrap {
      background: var(--white); border: 1px solid var(--border);
      border-radius: var(--radius-lg); overflow: hidden;
      box-shadow: var(--shadow); display: flex; flex-direction: column;
      margin-top: 14px; animation: fadeUp .4s ease .1s both;
    }
    .table-container {
      overflow: auto; width: 100%; max-height: 65vh; position: relative;
      -webkit-overflow-scrolling: touch;
    }
    .table-container::-webkit-scrollbar { height: 7px; width: 7px; }
    .table-container::-webkit-scrollbar-track { background: #f8fafc; }
    .table-container::-webkit-scrollbar-thumb { background: #CBD5E1; border-radius: 10px; }
    .table-container::-webkit-scrollbar-thumb:hover { background: #94A3B8; }

    table { width: 100%; border-collapse: separate; border-spacing: 0; }

    /* ══════════════════════════════════════
       THEAD — Dual Row (Label + Filter)
       ══════════════════════════════════════ */
    thead th {
      position: sticky; top: 0; z-index: 20; padding: 13px 14px 10px;
      text-align: left; font-size: 10px; font-weight: 700;
      letter-spacing: .08em; text-transform: uppercase; color: var(--navy);
      background: linear-gradient(180deg, #F8FAFC 0%, #F1F5F9 100%);
      border-bottom: 1px solid var(--border); white-space: nowrap;
      box-shadow: 0 2px 4px rgba(15,31,53,.04);
    }
    /* Filter row */
    thead tr.filter-row th {
      position: sticky; top: 42px; z-index: 19;
      padding: 8px 6px 10px; background: #F1F5F9;
      border-bottom: 2px solid var(--border);
      box-shadow: 0 2px 6px rgba(15,31,53,.05);
    }
    .col-filter {
      width: 100%; padding: 6px 8px; border: 1px solid #E2E8F0;
      border-radius: 7px; font-size: 11px; font-weight: 500;
      color: var(--navy); background: #fff; outline: none;
      font-family: var(--sans); transition: all .2s;
      -webkit-appearance: none; appearance: none; cursor: pointer;
    }
    select.col-filter {
      padding-right: 22px;
      background: #fff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='%2394A3B8' stroke-width='3'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E") no-repeat right 7px center;
      background-size: 10px;
    }
    .col-filter:focus { border-color: var(--teal); box-shadow: 0 0 0 2px rgba(13,148,136,.1); }
    .col-filter::placeholder { color: #B0BEC5; font-weight: 400; }
    .col-filter.active-filter { border-color: var(--teal); background: rgba(13,148,136,.04); }

    /* ══════════════════════════════════════
       TBODY
       ══════════════════════════════════════ */
    tbody tr { transition: all .2s ease; }
    tbody tr:nth-child(even) { background: #FAFCFE; }
    tbody tr:hover {
      background: linear-gradient(90deg, rgba(13,148,136,.04) 0%, rgba(30,58,95,.04) 100%);
      transform: scale(1.001);
    }
    tbody tr td {
      padding: 12px 14px; font-size: 13px; color: var(--text2);
      border-bottom: 1px solid #EEF2F7; white-space: nowrap; transition: all .15s;
    }
    tbody tr:last-child td { border-bottom: none; }
    tbody tr:hover td { color: var(--navy); }
    tbody tr:hover td:first-child { border-left: 3px solid var(--teal); padding-left: 11px; }

    .badge {
      display: inline-flex; padding: 4px 10px; border-radius: 99px;
      font-size: 11px; font-weight: 600; border: 1px solid transparent;
    }

    /* ══════════════════════════════════════
       BOTTOM BAR
       ══════════════════════════════════════ */
    .bottom-bar {
      display: flex; align-items: center; justify-content: space-between;
      padding: 14px 20px; background: #F8FAFC; border-top: 1px solid var(--border);
      flex-wrap: wrap; gap: 12px;
    }
    .count-info { font-size: 13px; color: var(--text3); font-weight: 500; }
    .no-data { text-align: center; padding: 40px; color: var(--text3); }
    .pagination-wrap { display: flex; align-items: center; gap: 8px; }
    .pagination-btn {
      padding: 7px 14px; background: #fff; border: 1px solid var(--border2);
      border-radius: 9px; font-size: 13px; font-weight: 600; color: var(--text2);
      cursor: pointer; transition: all .2s; outline: none;
    }
    .pagination-btn:hover:not(:disabled) { background: var(--ice); border-color: var(--teal); color: var(--teal); }
    .pagination-btn:disabled { opacity: .4; cursor: not-allowed; }
    .page-info { font-size: 13px; font-weight: 600; color: var(--navy); min-width: 110px; text-align: center; }

    /* Active filter count badge */
    .filter-count {
      display: inline-flex; align-items: center; justify-content: center;
      min-width: 20px; height: 20px; padding: 0 6px;
      border-radius: 99px; font-size: 10px; font-weight: 700;
      background: var(--teal); color: #fff;
      box-shadow: 0 2px 6px rgba(13,148,136,.3);
    }
    .filter-count.hidden { display: none; }

    /* Sortable headers */
    thead tr:first-child th.sortable {
      cursor: pointer; user-select: none; position: relative; padding-right: 22px;
    }
    thead tr:first-child th.sortable:hover { color: var(--teal); }
    thead tr:first-child th.sortable::after {
      content: '⇅'; position: absolute; right: 6px; top: 50%; transform: translateY(-50%);
      font-size: 11px; color: #CBD5E1; transition: color .2s;
    }
    thead tr:first-child th.sortable:hover::after { color: var(--teal); }
    thead tr:first-child th.sort-asc::after { content: '↑'; color: var(--teal); font-weight: 700; }
    thead tr:first-child th.sort-desc::after { content: '↓'; color: var(--teal); font-weight: 700; }

    /* Rows-per-page */
    .rpp-group { display: flex; align-items: center; gap: 8px; }
    .rpp-group label { font-size: 12px; color: var(--text3); font-weight: 500; white-space: nowrap; }
    .rpp-select {
      padding: 5px 24px 5px 10px; border: 1px solid var(--border2); border-radius: 8px;
      font-size: 12px; font-weight: 600; color: var(--navy); background: #fff;
      outline: none; cursor: pointer; font-family: var(--sans);
      -webkit-appearance: none; appearance: none;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='%2394A3B8' stroke-width='3'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
      background-repeat: no-repeat; background-position: right 7px center; background-size: 10px;
    }
    .rpp-select:focus { border-color: var(--teal); box-shadow: 0 0 0 2px rgba(13,148,136,.1); }
  </style>
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

  {{-- GLOBAL SEARCH BAR --}}
  <div class="global-search">
    <div class="global-search__icon">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
    </div>
    <div class="global-search__wrap">
      <span class="global-search__search-icon">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      </span>
      <input type="text" id="globalSearch" class="global-search__input" placeholder="Cari di semua kolom — nama, email, daerah, pendidikan, peran...">
    </div>
    <div class="global-search__info">
      <span id="searchMatchCount">{{ count($users) }}</span> hasil
      <span class="filter-count hidden" id="activeFilterCount">0</span>
    </div>
    <button class="global-search__clear" id="clearAllBtn" onclick="clearAll()">✕ Reset</button>
  </div>

  {{-- TABLE --}}
  <div class="table-wrap">
    <div class="table-container">
      <table>
        <thead>
          {{-- Label Row (sortable) --}}
          <tr>
            <th style="width:50px">No</th>
            <th class="sortable" data-sort="name" onclick="toggleSort('name')">Nama</th>
            <th class="sortable" data-sort="email" onclick="toggleSort('email')">Email</th>
            <th class="sortable" data-sort="gender" onclick="toggleSort('gender')">Gender</th>
            <th class="sortable" data-sort="age" onclick="toggleSort('age')">Umur</th>
            <th class="sortable" data-sort="region" onclick="toggleSort('region')">Daerah Asal</th>
            <th class="sortable" data-sort="education" onclick="toggleSort('education')">Pendidikan</th>
            <th class="sortable" data-sort="role" onclick="toggleSort('role')">Peran Harian</th>
            <th class="sortable" data-sort="qcount" onclick="toggleSort('qcount')">Total Kuesioner</th>
            <th style="text-align:center">Aksi</th>
          </tr>
          {{-- Per-Column Filter Row --}}
          <tr class="filter-row">
            <th></th>
            <th><input type="text" class="col-filter" id="fName" placeholder="Filter nama..." oninput="applyFilters()"></th>
            <th><input type="text" class="col-filter" id="fEmail" placeholder="Filter email..." oninput="applyFilters()"></th>
            <th>
              <select class="col-filter" id="fGender" onchange="applyFilters()">
                <option value="">Semua</option>
                <option value="Male">Laki-laki</option>
                <option value="Female">Perempuan</option>
              </select>
            </th>
            <th>
              <select class="col-filter" id="fAge" onchange="applyFilters()">
                <option value="">Semua</option>
                <option value="0-17">≤ 17</option>
                <option value="18-25">18 – 25</option>
                <option value="26-35">26 – 35</option>
                <option value="36-50">36 – 50</option>
                <option value="51+">51+</option>
              </select>
            </th>
            <th><input type="text" class="col-filter" id="fRegion" placeholder="Filter daerah..." oninput="applyFilters()"></th>
            <th><input type="text" class="col-filter" id="fEducation" placeholder="Filter..." oninput="applyFilters()"></th>
            <th>
              <select class="col-filter" id="fRole" onchange="applyFilters()">
                <option value="">Semua</option>
                <option value="Student">Mahasiswa</option>
                <option value="Worker">Pekerja</option>
                <option value="Unemployed">Tidak Bekerja</option>
              </select>
            </th>
            <th>
              <select class="col-filter" id="fQcount" onchange="applyFilters()">
                <option value="">Semua</option>
                <option value="0">0</option>
                <option value="1+">≥ 1</option>
                <option value="3+">≥ 3</option>
                <option value="5+">≥ 5</option>
              </select>
            </th>
            <th></th>
          </tr>
        </thead>
        <tbody id="tableBody">
          @forelse($users as $index => $user)
            @php
              $roleMap = ['Student'=>'Mahasiswa','Worker'=>'Pekerja','Unemployed'=>'Tidak Bekerja'];
              $roleIndo = $roleMap[$user->daily_role] ?? ($user->daily_role ?? '-');
            @endphp
            <tr data-name="{{ strtolower($user->name) }}"
                data-email="{{ strtolower($user->email) }}"
                data-gender="{{ $user->gender }}"
                data-age="{{ $user->age ?? '' }}"
                data-region="{{ strtolower($user->region ?? '') }}"
                data-education="{{ strtolower($user->education_level ?? '') }}"
                data-role="{{ $user->daily_role }}"
                data-qcount="{{ $user->questionnaire_count ?? 0 }}"
                data-created="{{ $user->created_at }}"
                data-search="{{ strtolower($user->name.' '.$user->email.' '.($user->region ?? '').' '.($user->education_level ?? '').' '.$roleIndo.' '.($user->daily_role ?? '')) }}">
              <td style="color:var(--text3); font-weight:600;">{{ $index + 1 }}</td>
              <td>
                <div style="display:flex;align-items:center;gap:10px;">
                  <div style="width:32px;height:32px;border-radius:50%;background:var(--ice);color:var(--teal);display:flex;align-items:center;justify-content:center;font-weight:700;font-size:11px;border:1px solid var(--teal-lt);">{{ strtoupper(substr($user->name,0,2)) }}</div>
                  <div style="font-weight:600;color:var(--navy);">{{ $user->name }}</div>
                </div>
              </td>
              <td style="color:var(--text3);">{{ $user->email }}</td>
              <td>
                @if($user->gender=='Male')
                  <span class="badge" style="background:rgba(59,130,246,.1);color:#3b82f6;border-color:rgba(59,130,246,.2);">Laki-laki</span>
                @elseif($user->gender=='Female')
                  <span class="badge" style="background:rgba(236,72,153,.1);color:#ec4899;border-color:rgba(236,72,153,.2);">Perempuan</span>
                @else <span style="color:var(--text3);">-</span> @endif
              </td>
              <td style="font-weight:600;">{{ $user->age ?? '-' }} thn</td>
              <td>{{ $user->region ?? '-' }}</td>
              <td>{{ $user->education_level ?? '-' }}</td>
              <td>{{ $roleIndo }}</td>
              <td style="text-align:center;font-weight:700;color:var(--teal);">{{ $user->questionnaire_count ?? 0 }}</td>
              <td style="text-align:center;">
                <form method="POST" action="{{ route('admin.users.destroy', $user->id) }}" onsubmit="return confirm('Hapus pengguna ini?')">
                  @csrf @method('DELETE')
                  <button type="submit" style="background:none;border:none;color:var(--red);cursor:pointer;font-size:12px;font-weight:600;padding:4px 8px;border-radius:6px;transition:.2s;" onmouseover="this.style.background='var(--red-lt)'" onmouseout="this.style.background='none'">Hapus</button>
                </form>
              </td>
            </tr>
          @empty
            <tr><td colspan="10" class="no-data">Tidak ada data pengguna</td></tr>
          @endforelse
        </tbody>
      </table>
    </div>

    {{-- BOTTOM BAR --}}
    <div class="bottom-bar">
      <div class="pagination-wrap">
        <button class="pagination-btn" id="prevBtn" onclick="prevPage()">← Sebelumnya</button>
        <span class="page-info" id="pageInfo">Halaman 1 dari 1</span>
        <button class="pagination-btn" id="nextBtn" onclick="nextPage()">Selanjutnya →</button>
      </div>
      <div style="display:flex;align-items:center;gap:16px;">
        <div class="rpp-group">
          <label>Baris/halaman:</label>
          <select class="rpp-select" id="rowsPerPageSelect" onchange="changeRowsPerPage()">
            <option value="25">25</option>
            <option value="50" selected>50</option>
            <option value="100">100</option>
            <option value="200">200</option>
          </select>
        </div>
        <span class="count-info" id="countInfo">Menampilkan 0 data</span>
      </div>
    </div>
  </div>

  {{-- Route bridge for JS --}}
  <div id="route-data" data-destroy-base="/admin/users" data-csrf="{{ csrf_token() }}" hidden></div>

@endsection

@push('scripts')
<script>
let currentPage = 1;
let rowsPerPage = 50;
let filteredRows = [];
let currentSort = { key: '', dir: '' };

window.onload = () => applyFilters();

document.getElementById('globalSearch').addEventListener('input', () => applyFilters());

/* ── Column Sorting ── */
function toggleSort(key) {
  if (currentSort.key === key) {
    currentSort.dir = currentSort.dir === 'asc' ? 'desc' : (currentSort.dir === 'desc' ? '' : 'asc');
    if (!currentSort.dir) currentSort.key = '';
  } else {
    currentSort.key = key;
    currentSort.dir = 'asc';
  }
  // Update header UI
  document.querySelectorAll('thead tr:first-child th.sortable').forEach(th => {
    th.classList.remove('sort-asc','sort-desc');
    if (th.dataset.sort === currentSort.key && currentSort.dir) {
      th.classList.add('sort-' + currentSort.dir);
    }
  });
  sortAndRender();
}

function sortAndRender() {
  if (currentSort.key && currentSort.dir) {
    const k = currentSort.key;
    const dir = currentSort.dir === 'asc' ? 1 : -1;
    filteredRows.sort((a, b) => {
      let va = a.dataset[k] || '';
      let vb = b.dataset[k] || '';
      // Numeric columns
      if (['age','qcount'].includes(k)) {
        return (parseFloat(va||0) - parseFloat(vb||0)) * dir;
      }
      return va.localeCompare(vb) * dir;
    });
  } else {
    filteredRows.sort((a, b) => (b.dataset.created||'').localeCompare(a.dataset.created||''));
  }
  currentPage = 1;
  renderTable();
}

/* ── Filters ── */
function applyFilters() {
  const gs = document.getElementById('globalSearch').value.toLowerCase().trim();
  const fN = document.getElementById('fName').value.toLowerCase().trim();
  const fE = document.getElementById('fEmail').value.toLowerCase().trim();
  const fG = document.getElementById('fGender').value;
  const fA = document.getElementById('fAge').value;
  const fR = document.getElementById('fRegion').value.toLowerCase().trim();
  const fEd = document.getElementById('fEducation').value.toLowerCase().trim();
  const fRo = document.getElementById('fRole').value;
  const fQ = document.getElementById('fQcount').value;

  const allRows = Array.from(document.getElementById('tableBody').querySelectorAll('tr[data-search]'));

  filteredRows = allRows.filter(row => {
    if (gs && !row.dataset.search.includes(gs)) return false;
    if (fN && !row.dataset.name.includes(fN)) return false;
    if (fE && !row.dataset.email.includes(fE)) return false;
    if (fG && row.dataset.gender !== fG) return false;
    if (fR && !row.dataset.region.includes(fR)) return false;
    if (fEd && !row.dataset.education.includes(fEd)) return false;
    if (fRo && row.dataset.role !== fRo) return false;
    if (fA) {
      const age = parseInt(row.dataset.age);
      if (isNaN(age)) return false;
      if (fA === '0-17' && age > 17) return false;
      if (fA === '18-25' && (age < 18 || age > 25)) return false;
      if (fA === '26-35' && (age < 26 || age > 35)) return false;
      if (fA === '36-50' && (age < 36 || age > 50)) return false;
      if (fA === '51+' && age < 51) return false;
    }
    if (fQ) {
      const qc = parseInt(row.dataset.qcount || 0);
      if (fQ === '0' && qc !== 0) return false;
      if (fQ === '1+' && qc < 1) return false;
      if (fQ === '3+' && qc < 3) return false;
      if (fQ === '5+' && qc < 5) return false;
    }
    return true;
  });

  updateFilterUI();
  sortAndRender();
}

function updateFilterUI() {
  let count = 0;
  ['fName','fEmail','fGender','fAge','fRegion','fEducation','fRole','fQcount'].forEach(id => {
    const el = document.getElementById(id);
    const on = el.value.trim() !== '';
    if (on) count++;
    el.classList.toggle('active-filter', on);
  });
  if (document.getElementById('globalSearch').value.trim()) count++;
  const badge = document.getElementById('activeFilterCount');
  badge.textContent = count;
  badge.classList.toggle('hidden', count === 0);
  document.getElementById('searchMatchCount').textContent = filteredRows.length;
}

function renderTable() {
  const tbody = document.getElementById('tableBody');
  const total = filteredRows.length;
  const totalPages = Math.ceil(total / rowsPerPage) || 1;
  if (currentPage > totalPages) currentPage = totalPages;
  if (currentPage < 1) currentPage = 1;
  const start = (currentPage - 1) * rowsPerPage;
  const end = start + rowsPerPage;

  Array.from(tbody.querySelectorAll('tr[data-search]')).forEach(r => r.style.display = 'none');

  const pageRows = filteredRows.slice(start, end);
  pageRows.forEach((row, i) => {
    row.style.display = '';
    row.querySelector('td:first-child').textContent = start + i + 1;
    tbody.appendChild(row);
  });

  document.getElementById('pageInfo').textContent = 'Halaman ' + currentPage + ' dari ' + totalPages;
  document.getElementById('prevBtn').disabled = currentPage === 1;
  document.getElementById('nextBtn').disabled = currentPage === totalPages;
  document.getElementById('countInfo').textContent = 'Menampilkan ' + pageRows.length + ' dari ' + total + ' pengguna';
  document.querySelector('.table-container').scrollTop = 0;
}

function nextPage() { currentPage++; renderTable(); }
function prevPage() { currentPage--; renderTable(); }

function changeRowsPerPage() {
  rowsPerPage = parseInt(document.getElementById('rowsPerPageSelect').value);
  currentPage = 1;
  renderTable();
}

function clearAll() {
  document.getElementById('globalSearch').value = '';
  ['fName','fEmail','fRegion','fEducation'].forEach(id => document.getElementById(id).value = '');
  ['fGender','fAge','fRole','fQcount'].forEach(id => document.getElementById(id).value = '');
  currentSort = { key: '', dir: '' };
  document.querySelectorAll('thead tr:first-child th.sortable').forEach(th => th.classList.remove('sort-asc','sort-desc'));
  applyFilters();
}

document.addEventListener('click', function(e) {
  if (!e.target.closest('.custom-dd')) {
    document.querySelectorAll('.custom-dd.open').forEach(d => d.classList.remove('open'));
  }
});
</script>
@endpush