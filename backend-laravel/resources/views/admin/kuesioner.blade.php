{{--
  ═══════════════════════════════════════════════
  resources/views/admin/kuesioner.blade.php
  Halaman Data Kuesioner — Activa Admin
  ═══════════════════════════════════════════════
--}}
@extends('layouts.app')
@section('title','Data Kuesioner — Activa')
@section('page-title','Data Kuesioner')

@section('topbar-actions')
  <button class="btn btn-ghost btn-sm" onclick="refreshData()">⟳ Refresh</button>
@endsection

@push('styles')
<style>
  .table-wrap {
    background: var(--white);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    overflow: hidden;
    box-shadow: var(--shadow);
    width: 100%;
    max-width: 100%;
    display: flex;
    flex-direction: column;
    margin-top: 10px;
  }

  .table-container {
    overflow: auto; /* Enable both x and y scrolling */
    width: 100%;
    max-height: 70vh; /* Set a professional fixed height for the table area */
    position: relative;
    /* Smooth scrolling for touch devices */
    -webkit-overflow-scrolling: touch;
  }

  /* Custom Scrollbar styling for a professional look */
  .table-container::-webkit-scrollbar {
    height: 8px;
    width: 8px;
  }
  .table-container::-webkit-scrollbar-track {
    background: #f8fafc;
  }
  .table-container::-webkit-scrollbar-thumb {
    background: var(--border2);
    border-radius: 10px;
    border: 2px solid #f8fafc;
  }
  .table-container::-webkit-scrollbar-thumb:hover {
    background: var(--text3);
  }

  table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    min-width: 1800px;
  }

  thead th {
    position: sticky;
    top: 0;
    z-index: 20;
    padding: 14px 16px;
    text-align: left;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--navy);
    background: linear-gradient(180deg, #F8FAFC 0%, #F1F5F9 100%);
    border-bottom: 2px solid var(--border);
    white-space: nowrap;
    box-shadow: 0 2px 4px rgba(15,31,53,.04);
  }

  tbody tr {
    transition: all 0.2s ease;
  }
  tbody tr:nth-child(even) {
    background: #FAFCFE;
  }
  tbody tr:hover {
    background: linear-gradient(90deg, rgba(13,148,136,.04) 0%, rgba(30,58,95,.04) 100%);
    transform: scale(1.001);
  }

  tbody tr td {
    padding: 13px 16px;
    font-size: 13px;
    color: var(--text2);
    border-bottom: 1px solid #EEF2F7;
    white-space: nowrap;
    transition: all 0.15s ease;
  }

  tbody tr:last-child td {
    border-bottom: none;
  }

  tbody tr:hover td {
    color: var(--navy);
  }

  tbody tr:hover td:first-child {
    border-left: 3px solid var(--teal);
    padding-left: 13px;
  }

  .badge {
    display: inline-flex;
    align-items: center;
    padding: 4px 10px;
    border-radius: 99px;
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.02em;
  }
  .badge-selesai   { background: rgba(13,148,136,.1); color: #0d9488; border: 1px solid rgba(13,148,136,.2); }
  .badge-sangat-tinggi { background: rgba(220,38,38,.1); color: #dc2626; border: 1px solid rgba(220,38,38,.2); }
  .badge-tinggi    { background: rgba(234,88,12,.1);  color: #ea580c; border: 1px solid rgba(234,88,12,.2); }
  .badge-sedang    { background: rgba(217,119,6,.1);  color: #d97706; border: 1px solid rgba(217,119,6,.2); }
  .badge-rendah    { background: rgba(22,163,74,.1);  color: #16a34a; border: 1px solid rgba(22,163,74,.2); }

  /* ── Toolbar ── */
  .toolbar {
    display: flex; gap: 12px; flex-wrap: wrap; align-items: center;
    padding: 20px; background: #FAFCFF; border-bottom: 1px solid var(--border);
  }
  .toolbar-group { display: flex; align-items: center; gap: 8px; }
  .toolbar label { font-size: 12px; font-weight: 600; color: var(--text2); white-space: nowrap; }
  .toolbar input[type="text"] {
    padding: 9px 14px; border: 1px solid var(--border2); border-radius: 10px;
    font-size: 13px; font-weight: 500; outline: none; color: var(--navy);
    background: #fff; transition: all 0.25s ease; width: 220px; font-family: var(--sans);
  }
  .toolbar input[type="text"]:focus { border-color: var(--teal); box-shadow: 0 0 0 3px rgba(13,148,136,.12); }
  .toolbar input[type="text"]:hover { border-color: var(--navy); background: #FAFCFF; }

  /* Custom Dropdown — Premium */
  .custom-dd { position: relative; min-width: 120px; }
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
    position: relative;
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

  /* ── Bottom bar ── */
  .bottom-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
    background: #F8FAFC;
    border-top: 1px solid var(--border);
    flex-wrap: wrap;
    gap: 16px;
  }
  .count-info { 
    font-size: 13px; 
    color: var(--text3);
    font-weight: 500;
  }

  .btn-export {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 20px;
    background: var(--teal);
    color: #fff;
    border: none;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    box-shadow: 0 4px 12px rgba(13, 148, 136, 0.2);
  }
  .btn-export:hover { 
    background: var(--teal-dk); 
    transform: translateY(-1px);
    box-shadow: 0 6px 15px rgba(13, 148, 136, 0.3);
  }
  .btn-export:active { transform: translateY(0); }

  /* ── Modal ── */
  .modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(15, 31, 53, 0.6);
    backdrop-filter: blur(4px);
    z-index: 1000;
    align-items: center;
    justify-content: center;
    padding: 20px;
    transition: all 0.3s;
  }
  .modal-overlay.open { display: flex; }

  .modal-box {
    background: #fff;
    border-radius: 20px;
    padding: 32px;
    width: 480px;
    max-width: 100%;
    max-height: 90vh;
    overflow-y: auto;
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
    position: relative;
    animation: modalSlideUp 0.3s ease-out;
  }

  @keyframes modalSlideUp {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .modal-box h3 {
    font-size: 18px;
    font-weight: 700;
    color: var(--navy);
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 10px;
  }
  
  .modal-rec-item {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 12px 16px;
    background: #F8FAFC;
    border-radius: 12px;
    margin-bottom: 10px;
    font-size: 14px;
    color: var(--text);
    line-height: 1.6;
    border: 1px solid #E2EAF2;
  }

  .rec-dot {
    width: 8px; height: 8px;
    border-radius: 50%;
    background: var(--teal);
    flex-shrink: 0;
    margin-top: 7px;
    box-shadow: 0 0 0 3px var(--teal-lt);
  }

  .modal-close-btn {
    margin-top: 24px;
    width: 100%;
    padding: 12px;
    border: 1px solid var(--border2);
    border-radius: 12px;
    background: #fff;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    color: var(--text2);
    transition: all 0.2s;
  }
  .modal-close-btn:hover { 
    background: #F1F5F9;
    color: var(--navy);
    border-color: var(--navy);
  }

  .no-data {
    text-align: center;
    padding: 60px 20px;
    color: var(--text3);
  }

  .btn-view {
    background: var(--ice);
    color: var(--teal);
    border: 1px solid var(--teal-lt);
    padding: 6px 14px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
  }

  .btn-view:hover {
    background: var(--teal);
    color: #fff;
    border-color: var(--teal);
  }

  /* ── Pagination ── */
  .pagination-wrap {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  .pagination-btn {
    padding: 6px 14px;
    background: #fff;
    border: 1px solid var(--border2);
    border-radius: 10px;
    font-size: 13px;
    font-weight: 600;
    color: var(--text2);
    cursor: pointer;
    transition: all 0.2s;
    outline: none;
  }
  .pagination-btn:hover:not(:disabled) {
    background: var(--ice);
    border-color: var(--teal);
    color: var(--teal);
  }
  .pagination-btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
  }
  .page-info {
    font-size: 13px;
    font-weight: 600;
    color: var(--navy);
    min-width: 120px;
    text-align: center;
  }

  /* ── Global Search Bar ── */
  .global-search {
    display: flex; align-items: center; gap: 14px;
    padding: 16px 22px; margin-bottom: 14px;
    background: var(--white); border: 1px solid var(--border);
    border-radius: var(--radius-lg); box-shadow: var(--shadow);
    animation: fadeUp .35s ease both;
  }
  @keyframes fadeUp { from { opacity:0; transform:translateY(14px); } to { opacity:1; transform:translateY(0); } }
  .global-search__icon {
    width: 40px; height: 40px; border-radius: 12px;
    background: linear-gradient(135deg, var(--teal), #34d399);
    display: flex; align-items: center; justify-content: center;
    color: #fff; flex-shrink: 0; box-shadow: 0 4px 12px rgba(13,148,136,.25);
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
  .filter-count {
    display: inline-flex; align-items: center; justify-content: center;
    min-width: 20px; height: 20px; padding: 0 6px; border-radius: 99px;
    font-size: 10px; font-weight: 700; background: var(--teal); color: #fff;
    box-shadow: 0 2px 6px rgba(13,148,136,.3);
  }
  .filter-count.hidden { display: none; }

  /* ── Per-Column Filter Row ── */
  thead tr.filter-row th {
    position: sticky; top: 42px; z-index: 19;
    padding: 6px 4px 8px; background: #F1F5F9;
    border-bottom: 2px solid var(--border);
    box-shadow: 0 2px 6px rgba(15,31,53,.05);
  }
  .col-filter {
    width: 100%; padding: 5px 6px; border: 1px solid #E2E8F0;
    border-radius: 6px; font-size: 10px; font-weight: 500;
    color: var(--navy); background: #fff; outline: none;
    font-family: var(--sans); transition: all .2s;
    -webkit-appearance: none; appearance: none;
  }
  select.col-filter {
    padding-right: 18px;
    background: #fff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='%2394A3B8' stroke-width='3'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E") no-repeat right 5px center;
    background-size: 9px;
  }
  .col-filter:focus { border-color: var(--teal); box-shadow: 0 0 0 2px rgba(13,148,136,.1); }
  .col-filter::placeholder { color: #B0BEC5; font-weight: 400; }
  .col-filter.active-filter { border-color: var(--teal); background: rgba(13,148,136,.04); }

  /* ── Sortable Headers ── */
  thead tr:first-child th.sortable {
    cursor: pointer; user-select: none; position: relative; padding-right: 20px;
  }
  thead tr:first-child th.sortable:hover { color: var(--teal); }
  thead tr:first-child th.sortable::after {
    content: '⇅'; position: absolute; right: 4px; top: 50%; transform: translateY(-50%);
    font-size: 10px; color: #CBD5E1; transition: color .2s;
  }
  thead tr:first-child th.sortable:hover::after { color: var(--teal); }
  thead tr:first-child th.sort-asc::after { content: '↑'; color: var(--teal); font-weight: 700; }
  thead tr:first-child th.sort-desc::after { content: '↓'; color: var(--teal); font-weight: 700; }

  /* ── Rows Per Page ── */
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

{{-- INFO BANNER --}}
<div class="alert alert-navy mb-5">
  <span style="font-size:16px;">≡</span>
  <div>
    <div style="font-weight:600;font-size:13px;margin-bottom:2px;">Data Respons Kuesioner User</div>
    <div style="font-size:12px;line-height:1.6;">Menampilkan semua respons kuesioner yang telah diisi oleh pengguna. Data ini digunakan untuk analisis ketergantungan digital pengguna.</div>
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
    <input type="text" id="globalSearch" class="global-search__input" placeholder="Cari di semua kolom — kategori, wilayah, gender, peran...">
  </div>
  <div class="global-search__info">
    <span id="searchMatchCount">0</span> hasil
    <span class="filter-count hidden" id="activeFilterCount">0</span>
  </div>
  <button class="global-search__clear" onclick="clearAll()">✕ Reset</button>
</div>

{{-- TABLE WRAP --}}
<div class="table-wrap">
  <div class="table-container">
    <table id="mainTable">
      <thead>
        {{-- Sortable Header Row --}}
        <tr>
          <th style="width:45px">No</th>
          <th class="sortable" data-sort="skor" onclick="toggleSort('skor')">Skor</th>
          <th class="sortable" data-sort="kategori" onclick="toggleSort('kategori')">Kategori</th>
          <th class="sortable" data-sort="gender" onclick="toggleSort('gender')">Gender</th>
          <th class="sortable" data-sort="umur" onclick="toggleSort('umur')">Umur</th>
          <th class="sortable" data-sort="region" onclick="toggleSort('region')">Wilayah</th>
          <th class="sortable" data-sort="pendidikan" onclick="toggleSort('pendidikan')">Pendidikan</th>
          <th class="sortable" data-sort="role" onclick="toggleSort('role')">Peran</th>
          <th class="sortable" data-sort="pendapatan" onclick="toggleSort('pendapatan')">Pendapatan</th>
          <th class="sortable" data-sort="device" onclick="toggleSort('device')">Jam Device</th>
          <th class="sortable" data-sort="bukahp" onclick="toggleSort('bukahp')">Buka HP</th>
          <th class="sortable" data-sort="notif" onclick="toggleSort('notif')">Notif</th>
          <th class="sortable" data-sort="medsos" onclick="toggleSort('medsos')">Medsos</th>
          <th class="sortable" data-sort="belajar" onclick="toggleSort('belajar')">Belajar</th>
          <th class="sortable" data-sort="fisik" onclick="toggleSort('fisik')">Fisik</th>
          <th class="sortable" data-sort="sleep" onclick="toggleSort('sleep')">Tidur</th>
          <th class="sortable" data-sort="sleepq" onclick="toggleSort('sleepq')">Kual. Tidur</th>
          <th class="sortable" data-sort="anxiety" onclick="toggleSort('anxiety')">Cemas</th>
          <th class="sortable" data-sort="depresi" onclick="toggleSort('depresi')">Depresi</th>
          <th class="sortable" data-sort="stres" onclick="toggleSort('stres')">Stres</th>
          <th class="sortable" data-sort="happy" onclick="toggleSort('happy')">Bahagia</th>
          <th>Perangkat</th>
          <th>Status</th>
          <th>Aksi</th>
        </tr>
        {{-- Per-Column Filter Row --}}
        <tr class="filter-row">
          <th></th>
          <th></th>
          <th>
            <select class="col-filter" id="fKategori" onchange="applyFilters()">
              <option value="">Semua</option>
              <option value="Sangat Tinggi">Sangat Tinggi</option>
              <option value="Tinggi">Tinggi</option>
              <option value="Sedang">Sedang</option>
              <option value="Rendah">Rendah</option>
            </select>
          </th>
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
              <option value="18-25">18–25</option>
              <option value="26-35">26–35</option>
              <option value="36-50">36–50</option>
              <option value="51+">51+</option>
            </select>
          </th>
          <th><input type="text" class="col-filter" id="fRegion" placeholder="Filter..." oninput="applyFilters()"></th>
          <th><input type="text" class="col-filter" id="fPendidikan" placeholder="Filter..." oninput="applyFilters()"></th>
          <th><input type="text" class="col-filter" id="fRole" placeholder="Filter..." oninput="applyFilters()"></th>
          <th><input type="text" class="col-filter" id="fPendapatan" placeholder="Filter..." oninput="applyFilters()"></th>
          <th></th><th></th><th></th><th></th><th></th><th></th>
          <th></th><th></th><th></th><th></th><th></th><th></th>
          <th><input type="text" class="col-filter" id="fPerangkat" placeholder="Filter..." oninput="applyFilters()"></th>
          <th></th>
          <th></th>
        </tr>
      </thead>
      <tbody id="tableBody">
        @forelse($kuesioner as $index => $item)
          @php
            $katClass = match($item['kategori']) {
              'Sangat Tinggi' => 'badge-sangat-tinggi',
              'Tinggi'        => 'badge-tinggi',
              'Sedang'        => 'badge-sedang',
              default         => 'badge-rendah',
            };
          @endphp
          <tr
            data-search="{{ strtolower($item['skor_ketergantungan'].' '.$item['kategori'].' '.$item['gender'].' '.$item['umur'].' '.$item['region'].' '.$item['tingkat_pendidikan'].' '.$item['peran_harian'].' '.$item['tingkat_pendapatan'].' '.$item['jam_perangkat_per_hari'].' '.$item['buka_hp_per_hari'].' '.$item['notifikasi_per_hari'].' '.$item['menit_medsos'].' '.$item['menit_belajar'].' '.$item['hari_aktif_fisik'].' '.$item['jam_tidur'].' '.$item['kualitas_tidur'].' '.$item['skor_kecemasan'].' '.$item['skor_depresi'].' '.$item['tingkat_stres'].' '.$item['skor_kebahagiaan'].' '.$item['jenis_perangkat']) }}"
            data-gender="{{ $item['gender'] }}"
            data-region="{{ strtolower($item['region']) }}"
            data-kategori="{{ $item['kategori'] }}"
            data-role="{{ strtolower($item['peran_harian']) }}"
            data-pendidikan="{{ strtolower($item['tingkat_pendidikan']) }}"
            data-pendapatan="{{ strtolower($item['tingkat_pendapatan']) }}"
            data-perangkat="{{ strtolower($item['jenis_perangkat']) }}"
            data-skor="{{ $item['skor_ketergantungan'] }}"
            data-umur="{{ $item['umur'] }}"
            data-device="{{ $item['jam_perangkat_per_hari'] }}"
            data-bukahp="{{ $item['buka_hp_per_hari'] }}"
            data-notif="{{ $item['notifikasi_per_hari'] }}"
            data-medsos="{{ $item['menit_medsos'] }}"
            data-belajar="{{ $item['menit_belajar'] }}"
            data-fisik="{{ $item['hari_aktif_fisik'] }}"
            data-sleep="{{ $item['jam_tidur'] }}"
            data-sleepq="{{ $item['kualitas_tidur'] }}"
            data-anxiety="{{ $item['skor_kecemasan'] }}"
            data-depresi="{{ $item['skor_depresi'] }}"
            data-stres="{{ $item['tingkat_stres'] }}"
            data-happy="{{ $item['skor_kebahagiaan'] }}"
          >
            <td style="text-align:center; color: var(--text3); font-weight: 600;">{{ $index + 1 }}</td>
            <td style="font-weight:700;color:var(--teal);">{{ $item['skor_ketergantungan'] }}</td>
            <td><span class="badge {{ $katClass }}">{{ $item['kategori'] }}</span></td>
            <td>{{ $item['gender'] }}</td>
            <td>{{ $item['umur'] }} thn</td>
            <td>{{ $item['region'] }}</td>
            <td>{{ $item['tingkat_pendidikan'] }}</td>
            <td>{{ $item['peran_harian'] }}</td>
            <td>{{ $item['tingkat_pendapatan'] }}</td>
            <td>{{ $item['jam_perangkat_per_hari'] }} jam</td>
            <td>{{ $item['buka_hp_per_hari'] }}x</td>
            <td>{{ $item['notifikasi_per_hari'] }}</td>
            <td>{{ $item['menit_medsos'] }} mnt</td>
            <td>{{ $item['menit_belajar'] }} mnt</td>
            <td>{{ $item['hari_aktif_fisik'] }} hari</td>
            <td>{{ $item['jam_tidur'] }} jam</td>
            <td>{{ $item['kualitas_tidur'] }}</td>
            <td>{{ $item['skor_kecemasan'] }}</td>
            <td>{{ $item['skor_depresi'] }}</td>
            <td>{{ $item['tingkat_stres'] }}</td>
            <td>{{ $item['skor_kebahagiaan'] }}</td>
            <td>{{ $item['jenis_perangkat'] }}</td>
            <td><span class="badge badge-selesai">Selesai</span></td>
            <td>
              <button class="btn-view"
                onclick="showRekomendasi(this)"
                data-recs='@json($item["rekomendasi"])'
                data-penyebab='@json($item["penyebab"])'
                data-uid="{{ $item['user_id'] }}">
                Lihat
              </button>
            </td>
          </tr>
        @empty
          <tr>
            <td colspan="24">
              <div class="no-data">
                <div style="font-size:48px;margin-bottom:16px; opacity: 0.5;">📋</div>
                <div style="font-size:16px;font-weight:700;color: var(--navy);margin-bottom:8px;">Belum ada data kuesioner</div>
                <div style="font-size:14px;color: var(--text3);">Kuesioner akan muncul di sini setelah user mulai mengisi</div>
              </div>
            </td>
          </tr>
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
      <button class="btn-export" onclick="exportXlsx()">⬇ Export .xlsx</button>
    </div>
  </div>
</div>

{{-- MODAL REKOMENDASI --}}
<div class="modal-overlay" id="modalOverlay" onclick="closeModal(event)">
  <div class="modal-box">
    <h3 id="modalTitle">Analisis & Rekomendasi</h3>
    <div id="modalContent"></div>
    <button class="modal-close-btn" onclick="document.getElementById('modalOverlay').classList.remove('open')">Tutup</button>
  </div>
</div>

@push('scripts')
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<script>
/* ── State ── */
let currentPage = 1;
let rowsPerPage = 50;
let filteredRows = [];
let currentSort = { key: '', dir: '' };
const numericCols = ['skor','umur','device','bukahp','notif','medsos','belajar','fisik','sleep','sleepq','anxiety','depresi','stres','happy'];

window.onload = () => applyFilters();
document.getElementById('globalSearch').addEventListener('input', () => applyFilters());

/* ── Column Sorting ── */
function toggleSort(key) {
  if (currentSort.key === key) {
    currentSort.dir = currentSort.dir === 'asc' ? 'desc' : (currentSort.dir === 'desc' ? '' : 'asc');
    if (!currentSort.dir) currentSort.key = '';
  } else {
    currentSort.key = key; currentSort.dir = 'asc';
  }
  document.querySelectorAll('thead tr:first-child th.sortable').forEach(th => {
    th.classList.remove('sort-asc','sort-desc');
    if (th.dataset.sort === currentSort.key && currentSort.dir) th.classList.add('sort-' + currentSort.dir);
  });
  sortAndRender();
}

function sortAndRender() {
  if (currentSort.key && currentSort.dir) {
    const k = currentSort.key, dir = currentSort.dir === 'asc' ? 1 : -1;
    filteredRows.sort((a, b) => {
      let va = a.dataset[k] || '', vb = b.dataset[k] || '';
      if (numericCols.includes(k)) return (parseFloat(va||0) - parseFloat(vb||0)) * dir;
      return va.localeCompare(vb) * dir;
    });
  }
  currentPage = 1;
  renderTable();
}

/* ── Filters ── */
function applyFilters() {
  const gs = document.getElementById('globalSearch').value.toLowerCase().trim();
  const fK = document.getElementById('fKategori').value;
  const fG = document.getElementById('fGender').value;
  const fA = document.getElementById('fAge').value;
  const fR = document.getElementById('fRegion').value.toLowerCase().trim();
  const fP = document.getElementById('fPendidikan').value.toLowerCase().trim();
  const fRo = document.getElementById('fRole').value.toLowerCase().trim();
  const fPd = document.getElementById('fPendapatan').value.toLowerCase().trim();
  const fPe = document.getElementById('fPerangkat').value.toLowerCase().trim();

  const allRows = Array.from(document.getElementById('tableBody').querySelectorAll('tr[data-search]'));

  filteredRows = allRows.filter(row => {
    if (gs && !row.dataset.search.includes(gs)) return false;
    if (fK && row.dataset.kategori !== fK) return false;
    if (fG && row.dataset.gender !== fG) return false;
    if (fR && !row.dataset.region.includes(fR)) return false;
    if (fP && !row.dataset.pendidikan.includes(fP)) return false;
    if (fRo && !row.dataset.role.includes(fRo)) return false;
    if (fPd && !row.dataset.pendapatan.includes(fPd)) return false;
    if (fPe && !row.dataset.perangkat.includes(fPe)) return false;
    if (fA) {
      const age = parseInt(row.dataset.umur);
      if (isNaN(age)) return false;
      if (fA === '0-17' && age > 17) return false;
      if (fA === '18-25' && (age < 18 || age > 25)) return false;
      if (fA === '26-35' && (age < 26 || age > 35)) return false;
      if (fA === '36-50' && (age < 36 || age > 50)) return false;
      if (fA === '51+' && age < 51) return false;
    }
    return true;
  });

  updateFilterUI();
  sortAndRender();
}

function updateFilterUI() {
  let count = 0;
  ['fKategori','fGender','fAge','fRegion','fPendidikan','fRole','fPendapatan','fPerangkat'].forEach(id => {
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
  document.getElementById('countInfo').textContent = 'Menampilkan ' + pageRows.length + ' dari ' + total + ' data';
  document.querySelector('.table-container').scrollTop = 0;
}

function nextPage() { currentPage++; renderTable(); }
function prevPage() { currentPage--; renderTable(); }
function changeRowsPerPage() { rowsPerPage = parseInt(document.getElementById('rowsPerPageSelect').value); currentPage = 1; renderTable(); }

function clearAll() {
  document.getElementById('globalSearch').value = '';
  ['fRegion','fPendidikan','fRole','fPendapatan','fPerangkat'].forEach(id => document.getElementById(id).value = '');
  ['fKategori','fGender','fAge'].forEach(id => document.getElementById(id).value = '');
  currentSort = { key: '', dir: '' };
  document.querySelectorAll('thead tr:first-child th.sortable').forEach(th => th.classList.remove('sort-asc','sort-desc'));
  applyFilters();
}

  /* ── Peta terjemahan penyebab ke Bahasa Indonesia ── */
  const penyebabTranslations = {
    // Kebahagiaan
    'happiness_low':            'Tingkat kebahagiaan rendah',
    'happiness_very_low':       'Tingkat kebahagiaan sangat rendah',
    'low_happiness':            'Tingkat kebahagiaan rendah',
    // Kecemasan
    'anxiety_high':             'Tingkat kecemasan tinggi',
    'anxiety_very_high':        'Tingkat kecemasan sangat tinggi',
    'high_anxiety':             'Tingkat kecemasan tinggi',
    // Depresi
    'depression_high':          'Tingkat depresi tinggi',
    'depression_very_high':     'Tingkat depresi sangat tinggi',
    'high_depression':          'Tingkat depresi tinggi',
    // Stres
    'stress_high':              'Tingkat stres tinggi',
    'stress_very_high':         'Tingkat stres sangat tinggi',
    'high_stress':              'Tingkat stres tinggi',
    // Tidur
    'sleep_low':                'Jam tidur kurang',
    'sleep_quality_low':        'Kualitas tidur buruk',
    'poor_sleep':               'Kualitas tidur buruk',
    'low_sleep_quality':        'Kualitas tidur rendah',
    'sleep_deprivation':        'Kurang tidur',
    // Penggunaan perangkat
    'device_hours_high':        'Penggunaan perangkat berlebihan',
    'high_device_usage':        'Penggunaan perangkat terlalu tinggi',
    'excessive_screen_time':    'Waktu layar berlebihan',
    'screen_time_high':         'Waktu layar terlalu tinggi',
    // Media sosial
    'social_media_high':        'Penggunaan media sosial berlebihan',
    'high_social_media':        'Penggunaan media sosial terlalu tinggi',
    'social_media_excessive':   'Media sosial berlebihan',
    // Aktivitas fisik
    'physical_activity_low':    'Aktivitas fisik kurang',
    'low_physical_activity':    'Kurang aktivitas fisik',
    'sedentary_lifestyle':      'Gaya hidup kurang gerak',
    // Notifikasi
    'notifications_high':       'Jumlah notifikasi terlalu banyak',
    'high_notifications':       'Notifikasi berlebihan',
    // Belajar
    'study_time_low':           'Waktu belajar kurang',
    'low_study_time':           'Waktu belajar rendah',
    // Buka HP
    'phone_unlocks_high':       'Terlalu sering membuka HP',
    'high_phone_unlocks':       'Frekuensi membuka HP tinggi',
    // Ketergantungan
    'digital_dependence_high':  'Ketergantungan digital tinggi',
    'high_digital_dependence':  'Ketergantungan digital tinggi',
  };

  /**
   * Ambil teks yang bisa ditampilkan dari sebuah item (bisa string, bisa object).
   */
  function extractText(item) {
    if (typeof item === 'string') return item;
    if (item && typeof item === 'object') {
      // Prioritaskan "isi" (konten Indonesia) daripada "tag" (key mentah seperti happiness_low)
      return item.isi || item.text || item.message || item.label || item.description
          || item.title || item.name || item.value || item.cause || item.reason
          || item.recommendation || item.action || item.suggestion
          || JSON.stringify(item);
    }
    return String(item);
  }

  /**
   * Terjemahkan key penyebab ke Bahasa Indonesia.
   * Kalau sudah dalam Bahasa Indonesia (tidak ditemukan di map), kembalikan apa adanya
   * dengan underscore diganti spasi dan huruf awal kapital.
   */
  function translatePenyebab(raw) {
    const text = extractText(raw);
    const key  = text.trim().toLowerCase().replace(/\s+/g, '_');
    if (penyebabTranslations[key]) return penyebabTranslations[key];
    // Fallback: capitalize dan ganti underscore
    return text.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
  }

  function showRekomendasi(btn) {
    const recs = JSON.parse(btn.dataset.recs);
    const penyebab = JSON.parse(btn.dataset.penyebab || '[]');
    const userId = btn.dataset.uid;
    
    document.getElementById('modalTitle').textContent = `Analisis & Rekomendasi`;
    const content = document.getElementById('modalContent');
    
    let html = '';
    
    // ── Penyebab Utama ──
    html += `<div style="margin-bottom:24px;">
                <h4 style="font-size:11px; color:var(--text3); text-transform:uppercase; margin-bottom:12px; letter-spacing:0.08em; font-weight:700;">Penyebab Utama</h4>`;
    if (penyebab && penyebab.length > 0) {
        html += penyebab.map(p => {
          const label = translatePenyebab(p);
          return `
          <div class="modal-rec-item" style="background:#FFF5F5; border-color:#FED7D7;">
            <div class="rec-dot" style="background:#E53E3E; box-shadow: 0 0 0 3px rgba(229, 62, 62, 0.1);"></div>
            <div style="color:#C53030; font-weight:500;">${label}</div>
          </div>`;
        }).join('');
    } else {
        html += `<div style="font-size:13px; color:var(--text3); padding:10px; background:#F8FAFC; border-radius:8px; text-align:center;">Data penyebab tidak tersedia</div>`;
    }
    html += `</div>`;
    
    // ── Rekomendasi Tindakan ──
    html += `<div>
                <h4 style="font-size:11px; color:var(--text3); text-transform:uppercase; margin-bottom:12px; letter-spacing:0.08em; font-weight:700;">Rekomendasi Tindakan</h4>`;
    if (recs && recs.length > 0) {
        html += recs.map(r => {
          const text = extractText(r);
          return `<div class="modal-rec-item"><div class="rec-dot"></div><div>${text}</div></div>`;
        }).join('');
    } else {
        html += `<div style="font-size:13px; color:var(--text3); padding:10px; background:#F8FAFC; border-radius:8px; text-align:center;">Data rekomendasi tidak tersedia</div>`;
    }
    html += `</div>`;
    
    content.innerHTML = html;
    document.getElementById('modalOverlay').classList.add('open');
}

  function closeModal(e) {
    if (e.target === document.getElementById('modalOverlay')) {
      document.getElementById('modalOverlay').classList.remove('open');
    }
  }

  /* ── Export XLSX ── */
  function exportXlsx() {
    const headers = [
      'No','Skor Ketergantungan','Kategori','Gender','Umur','Wilayah',
      'Pendidikan','Peran Harian','Pendapatan',
      'Jam Perangkat/Hari','Buka HP/Hari','Notifikasi/Hari',
      'Menit Medsos','Menit Belajar','Aktif Fisik',
      'Jam Tidur','Kualitas Tidur','Skor Kecemasan',
      'Skor Depresi','Tingkat Stres','Skor Kebahagiaan','Jenis Perangkat','Status'
    ];
    const data = [headers];
    
    // Export ALL filtered rows, not just the visible page
    filteredRows.forEach((row, i) => {
      const cells = Array.from(row.querySelectorAll('td'));
      const rowData = cells.slice(0, cells.length - 1).map(td => td.textContent.trim());
      rowData[0] = i + 1; // Correct index for export
      data.push(rowData);
    });

    const wb = XLSX.utils.book_new();
    const ws = XLSX.utils.aoa_to_sheet(data);
    XLSX.utils.book_append_sheet(wb, ws, 'Data Kuesioner');
    XLSX.writeFile(wb, 'data-kuesioner-activa.xlsx');
  }

  /* ── Refresh ── */
  function refreshData() { location.reload(); }

</script>
@endpush

@endsection