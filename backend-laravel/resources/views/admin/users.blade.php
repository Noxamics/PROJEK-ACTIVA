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
    /* Sinkronisasi dengan desain Kuesioner */
    .table-wrap {
      background: var(--white);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      overflow: hidden;
      box-shadow: var(--shadow);
      display: flex;
      flex-direction: column;
      margin-top: 10px;
    }
    .toolbar {
      display: flex; gap: 12px; flex-wrap: wrap; align-items: center; padding: 20px;
      background: #FAFCFF; border-bottom: 1px solid var(--border);
    }
    .toolbar-group { display: flex; align-items: center; gap: 8px; }
    .toolbar label { font-size: 12px; font-weight: 600; color: var(--text2); }
    .toolbar select, .toolbar input {
      padding: 9px 14px; border: 1px solid var(--border2); border-radius: 10px;
      font-size: 13px; font-weight: 500; outline: none; color: var(--navy);
      background: #fff; transition: all 0.25s ease; font-family: var(--sans);
    }
    .toolbar input:focus { border-color: var(--teal); box-shadow: 0 0 0 3px rgba(13,148,136,.12); }
    .toolbar input:hover { border-color: var(--navy); background: #FAFCFF; }

    /* Custom Dropdown — Premium */
    .custom-dd { position: relative; min-width: 130px; }
    .custom-dd__btn {
      display: flex; align-items: center; justify-content: space-between; gap: 10px;
      padding: 10px 14px; background: #fff; border: 1.5px solid #E2E8F0;
      border-radius: 11px; font-size: 13px; font-weight: 500; color: var(--navy);
      cursor: pointer; transition: all 0.3s cubic-bezier(.4,0,.2,1);
      font-family: var(--sans); user-select: none; white-space: nowrap;
      box-shadow: 0 1px 2px rgba(15,31,53,.04);
    }
    .custom-dd__btn:hover {
      border-color: #94A3B8; background: #FAFCFF;
      box-shadow: 0 2px 8px rgba(15,31,53,.06);
    }
    .custom-dd.open .custom-dd__btn {
      border-color: var(--teal); background: #fff;
      box-shadow: 0 0 0 4px rgba(13,148,136,.08), 0 2px 8px rgba(15,31,53,.06);
    }
    .custom-dd__arrow {
      width: 15px; height: 15px; flex-shrink: 0; color: #94A3B8;
      transition: all 0.3s cubic-bezier(.4,0,.2,1);
    }
    .custom-dd.open .custom-dd__arrow { transform: rotate(180deg); color: var(--teal); }
    .custom-dd__menu {
      position: absolute; top: calc(100% + 8px); left: 0; min-width: 100%; z-index: 100;
      background: rgba(255,255,255,.98); backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
      border: 1px solid rgba(226,232,240,.8); border-radius: 14px;
      box-shadow: 0 16px 48px rgba(15,31,53,.10), 0 4px 12px rgba(15,31,53,.04);
      padding: 5px; opacity: 0; transform: translateY(-6px) scale(.98);
      pointer-events: none; transition: all 0.25s cubic-bezier(.4,0,.2,1);
      max-height: 280px; overflow-y: auto;
    }
    .custom-dd__menu::-webkit-scrollbar { width: 5px; }
    .custom-dd__menu::-webkit-scrollbar-track { background: transparent; }
    .custom-dd__menu::-webkit-scrollbar-thumb { background: #CBD5E1; border-radius: 10px; }
    .custom-dd.open .custom-dd__menu {
      opacity: 1; transform: translateY(0) scale(1); pointer-events: auto;
    }
    .custom-dd__item {
      padding: 10px 13px; border-radius: 9px; font-size: 13px; font-weight: 500;
      color: #475569; cursor: pointer; transition: all 0.18s ease;
      display: flex; align-items: center; gap: 10px; margin: 1px 0;
    }
    .custom-dd__item:hover {
      background: linear-gradient(135deg, #F0FDFA 0%, #F0F9FF 100%);
      color: var(--navy); padding-left: 16px;
    }
    .custom-dd__item.active {
      background: linear-gradient(135deg, rgba(13,148,136,.06) 0%, rgba(13,148,136,.03) 100%);
      color: var(--teal); font-weight: 600;
    }
    .custom-dd__item.active::before {
      content: ''; width: 6px; height: 6px; border-radius: 50%;
      background: var(--teal); box-shadow: 0 0 0 3px rgba(13,148,136,.15);
      flex-shrink: 0;
    }
    .table-container {
      overflow: auto; width: 100%; max-height: 70vh; position: relative;
    }
    table { width: 100%; border-collapse: separate; border-spacing: 0; }
    thead th {
      position: sticky; top: 0; z-index: 20; padding: 14px 16px;
      text-align: left; font-size: 10px; font-weight: 700; letter-spacing: 0.08em;
      text-transform: uppercase; color: var(--navy);
      background: linear-gradient(180deg, #F8FAFC 0%, #F1F5F9 100%);
      border-bottom: 2px solid var(--border); white-space: nowrap;
      box-shadow: 0 2px 4px rgba(15,31,53,.04);
    }
    tbody tr { transition: all 0.2s ease; }
    tbody tr:nth-child(even) { background: #FAFCFE; }
    tbody tr:hover {
      background: linear-gradient(90deg, rgba(13,148,136,.04) 0%, rgba(30,58,95,.04) 100%);
      transform: scale(1.001);
    }
    tbody tr td {
      padding: 13px 16px; font-size: 13px; color: var(--text2);
      border-bottom: 1px solid #EEF2F7; white-space: nowrap;
      transition: all 0.15s ease;
    }
    tbody tr:last-child td { border-bottom: none; }
    tbody tr:hover td { color: var(--navy); }
    tbody tr:hover td:first-child { border-left: 3px solid var(--teal); padding-left: 13px; }
    .badge {
      display: inline-flex; padding: 4px 10px; border-radius: 99px;
      font-size: 11px; font-weight: 600; border: 1px solid transparent;
    }
    .bottom-bar {
      display: flex; align-items: center; justify-content: space-between;
      padding: 16px 20px; background: #F8FAFC; border-top: 1px solid var(--border);
      flex-wrap: wrap; gap: 12px;
    }
    .count-info { font-size: 13px; color: var(--text3); font-weight: 500; }
    .no-data { text-align: center; padding: 40px; color: var(--text3); }
    .pagination-wrap { display: flex; align-items: center; gap: 12px; }
    .pagination-btn {
      padding: 8px 16px; background: #fff; border: 1px solid var(--border2);
      border-radius: 10px; font-size: 13px; font-weight: 600; color: var(--text2);
      cursor: pointer; transition: all 0.2s; outline: none;
    }
    .pagination-btn:hover:not(:disabled) { background: var(--ice); border-color: var(--teal); color: var(--teal); }
    .pagination-btn:disabled { opacity: 0.4; cursor: not-allowed; }
    .page-info { font-size: 13px; font-weight: 600; color: var(--navy); min-width: 120px; text-align: center; }
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

  <div class="table-wrap">
    {{-- TOOLBAR --}}
    <div class="toolbar">
      <div class="toolbar-group">
        <label>Cari:</label>
        <input type="text" id="searchInput" placeholder="Nama atau email..." oninput="applyFilters()" style="width:200px;">
      </div>
      <div class="toolbar-group">
        <label>Peran:</label>
        <div class="custom-dd" id="ddRole">
          <div class="custom-dd__btn" onclick="toggleDD('ddRole')">
            <span>Semua</span>
            <svg class="custom-dd__arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
          </div>
          <div class="custom-dd__menu">
            <div class="custom-dd__item active" data-val="" onclick="selectDD('ddRole','fRole',this)">Semua</div>
            <div class="custom-dd__item" data-val="Student" onclick="selectDD('ddRole','fRole',this)">Mahasiswa</div>
            <div class="custom-dd__item" data-val="Worker" onclick="selectDD('ddRole','fRole',this)">Pekerja</div>
            <div class="custom-dd__item" data-val="Unemployed" onclick="selectDD('ddRole','fRole',this)">Tidak Bekerja</div>
          </div>
          <input type="hidden" id="fRole" value="">
        </div>
      </div>
      <div class="toolbar-group">
        <label>Gender:</label>
        <div class="custom-dd" id="ddGender">
          <div class="custom-dd__btn" onclick="toggleDD('ddGender')">
            <span>Semua</span>
            <svg class="custom-dd__arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
          </div>
          <div class="custom-dd__menu">
            <div class="custom-dd__item active" data-val="" onclick="selectDD('ddGender','fGender',this)">Semua</div>
            <div class="custom-dd__item" data-val="Male" onclick="selectDD('ddGender','fGender',this)">Laki-laki</div>
            <div class="custom-dd__item" data-val="Female" onclick="selectDD('ddGender','fGender',this)">Perempuan</div>
          </div>
          <input type="hidden" id="fGender" value="">
        </div>
      </div>
      <div class="toolbar-group">
        <label>Urutkan:</label>
        <div class="custom-dd" id="ddSort">
          <div class="custom-dd__btn" onclick="toggleDD('ddSort')">
            <span>Terbaru</span>
            <svg class="custom-dd__arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
          </div>
          <div class="custom-dd__menu">
            <div class="custom-dd__item active" data-val="latest" onclick="selectDD('ddSort','sortBy',this)">Terbaru</div>
            <div class="custom-dd__item" data-val="oldest" onclick="selectDD('ddSort','sortBy',this)">Terlama</div>
          </div>
          <input type="hidden" id="sortBy" value="latest">
        </div>
      </div>
    </div>

    {{-- TABLE CONTAINER --}}
    <div class="table-container">
      <table>
        <thead>
          <tr>
            <th>No</th><th>Nama</th><th>Email</th><th>Gender</th><th>Umur</th>
            <th>Daerah Asal</th><th>Pendidikan</th><th>Peran Harian</th>
            <th>Total Kuesioner</th><th style="text-align:center;">Aksi</th>
          </tr>
        </thead>
        <tbody id="tableBody">
          @forelse($users as $index => $user)
            @php
              $roleMap = ['Student'=>'Mahasiswa','Worker'=>'Pekerja','Unemployed'=>'Tidak Bekerja'];
              $roleIndo = $roleMap[$user->daily_role] ?? ($user->daily_role ?? '-');
            @endphp
            <tr data-search="{{ strtolower($user->name.' '.$user->email) }}"
                data-gender="{{ $user->gender }}"
                data-role="{{ $user->daily_role }}"
                data-created="{{ $user->created_at }}">
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
      <span class="count-info" id="countInfo">Menampilkan 0 data</span>
    </div>
  </div>


  {{-- Route bridge for JS --}}
  <div id="route-data" data-destroy-base="/admin/users" data-csrf="{{ csrf_token() }}" hidden></div>

@endsection

@push('scripts')
<script>
let currentPage = 1;
const rowsPerPage = 50;
let filteredRows = [];

window.onload = () => applyFilters();

function applyFilters() {
  const search = document.getElementById('searchInput').value.toLowerCase();
  const gender = document.getElementById('fGender').value;
  const role   = document.getElementById('fRole').value;
  const sort   = document.getElementById('sortBy').value;
  const tbody  = document.getElementById('tableBody');
  const allRows = Array.from(tbody.querySelectorAll('tr[data-search]'));

  filteredRows = allRows.filter(row => {
    const ok1 = !search || row.dataset.search.includes(search);
    const ok2 = !gender || row.dataset.gender === gender;
    const ok3 = !role   || row.dataset.role   === role;
    return ok1 && ok2 && ok3;
  });

  if (sort === 'oldest') {
    filteredRows.sort((a, b) => (a.dataset.created || '').localeCompare(b.dataset.created || ''));
  } else {
    filteredRows.sort((a, b) => (b.dataset.created || '').localeCompare(a.dataset.created || ''));
  }

  currentPage = 1;
  renderTable();
}

function renderTable() {
  const tbody = document.getElementById('tableBody');
  const total = filteredRows.length;
  const totalPages = Math.ceil(total / rowsPerPage) || 1;
  if (currentPage > totalPages) currentPage = totalPages;
  if (currentPage < 1) currentPage = 1;
  const start = (currentPage - 1) * rowsPerPage;
  const end = start + rowsPerPage;

  const allRows = Array.from(tbody.querySelectorAll('tr[data-search]'));
  allRows.forEach(r => r.style.display = 'none');

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

/* ── Custom Dropdown Logic ── */
function toggleDD(id) {
  const dd = document.getElementById(id);
  const wasOpen = dd.classList.contains('open');
  document.querySelectorAll('.custom-dd.open').forEach(d => d.classList.remove('open'));
  if (!wasOpen) dd.classList.add('open');
}

function selectDD(ddId, inputId, item) {
  document.getElementById(inputId).value = item.dataset.val;
  const dd = document.getElementById(ddId);
  dd.querySelector('.custom-dd__btn span').textContent = item.textContent;
  dd.querySelectorAll('.custom-dd__item').forEach(i => i.classList.remove('active'));
  item.classList.add('active');
  dd.classList.remove('open');
  applyFilters();
}

document.addEventListener('click', function(e) {
  if (!e.target.closest('.custom-dd')) {
    document.querySelectorAll('.custom-dd.open').forEach(d => d.classList.remove('open'));
  }
});
</script>
@endpush