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
  }

  .table-container {
    overflow-x: auto;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    min-width: 1400px;
  }

  thead th {
    padding: 12px 14px;
    text-align: left;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--navy);
    background: #EEF4FB;
    border-bottom: 2px solid var(--border2);
    white-space: nowrap;
  }

  tbody tr {
    border-bottom: 1px solid var(--border);
    transition: background 0.1s;
  }

  tbody tr:hover { background: #F5F9FF; }
  tbody tr:last-child { border-bottom: none; }

  td {
    padding: 11px 14px;
    font-size: 12.5px;
    white-space: nowrap;
  }

  .badge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 600;
  }
  .badge-selesai   { background: rgba(13,148,136,.12); color: #0d9488; }
  .badge-sangat-tinggi { background: rgba(220,38,38,.1); color: #dc2626; }
  .badge-tinggi    { background: rgba(234,88,12,.1);  color: #ea580c; }
  .badge-sedang    { background: rgba(217,119,6,.1);  color: #d97706; }
  .badge-rendah    { background: rgba(22,163,74,.1);  color: #16a34a; }

  /* ── Toolbar ── */
  .toolbar {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    align-items: center;
    padding: 16px 16px 0;
    margin-bottom: 14px;
  }

  .toolbar input[type="text"] {
    padding: 7px 12px;
    border: 1px solid var(--border2);
    border-radius: 8px;
    font-size: 12.5px;
    outline: none;
    width: 200px;
    color: var(--navy);
  }
  .toolbar input[type="text"]:focus { border-color: var(--teal); }

  .toolbar select {
    padding: 7px 10px;
    border: 1px solid var(--border2);
    border-radius: 8px;
    font-size: 12.5px;
    outline: none;
    color: var(--navy);
    background: #fff;
    cursor: pointer;
  }
  .toolbar select:focus { border-color: var(--teal); }

  .toolbar label {
    font-size: 12px;
    color: var(--text2);
    white-space: nowrap;
  }

  /* ── Bottom bar ── */
  .bottom-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 16px;
    border-top: 1px solid var(--border);
    flex-wrap: wrap;
    gap: 10px;
  }
  .count-info { font-size: 12px; color: var(--text3); }

  .btn-export {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 18px;
    background: var(--teal);
    color: #fff;
    border: none;
    border-radius: 8px;
    font-size: 12.5px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.15s;
  }
  .btn-export:hover { background: #0b7a72; }

  /* ── Modal ── */
  .modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,.45);
    z-index: 999;
    align-items: center;
    justify-content: center;
  }
  .modal-overlay.open { display: flex; }

  .modal-box {
    background: #fff;
    border-radius: 14px;
    padding: 28px;
    width: 420px;
    max-width: 95vw;
    max-height: 85vh;
    overflow-y: auto;
    box-shadow: 0 20px 60px rgba(0,0,0,.15);
  }
  .modal-box h3 {
    font-size: 15px;
    font-weight: 700;
    color: var(--navy);
    margin-bottom: 16px;
  }
  .modal-rec-item {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 9px 0;
    border-bottom: 1px solid #eef;
    font-size: 13px;
    color: var(--text2);
    line-height: 1.5;
  }
  .modal-rec-item:last-child { border-bottom: none; }
  .rec-dot {
    width: 7px; height: 7px;
    border-radius: 50%;
    background: var(--teal);
    flex-shrink: 0;
    margin-top: 5px;
  }
  .modal-close-btn {
    margin-top: 18px;
    width: 100%;
    padding: 9px;
    border: 1px solid var(--border2);
    border-radius: 8px;
    background: transparent;
    font-size: 13px;
    cursor: pointer;
    color: var(--text2);
  }
  .modal-close-btn:hover { background: #f5f9ff; }

  .no-data {
    text-align: center;
    padding: 48px 20px;
    color: var(--text3);
  }
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

{{-- TABLE WRAP --}}
<div class="table-wrap">

  {{-- TOOLBAR --}}
  <div class="toolbar">
    {{-- Search --}}
    <input type="text" id="searchInput" placeholder="🔍 Cari ID user, kategori..." oninput="applyFilters()">

    {{-- Filter gender --}}
    <select id="fGender" onchange="applyFilters()">
      <option value="">Semua Gender</option>
      <option>Laki-laki</option>
      <option>Perempuan</option>
    </select>

    {{-- Filter region --}}
    <select id="fRegion" onchange="applyFilters()">
      <option value="">Semua Region</option>
      @foreach($regions as $r)
        <option>{{ $r }}</option>
      @endforeach
    </select>

    {{-- Filter kategori --}}
    <select id="fKategori" onchange="applyFilters()">
      <option value="">Semua Kategori</option>
      <option>Sangat Tinggi</option>
      <option>Tinggi</option>
      <option>Sedang</option>
      <option>Rendah</option>
    </select>

    {{-- Filter daily role --}}
    <select id="fRole" onchange="applyFilters()">
      <option value="">Semua Role</option>
      @foreach($roles as $r)
        <option>{{ $r }}</option>
      @endforeach
    </select>

    {{-- Sort --}}
    <label>Urutkan:</label>
    <select id="sortBy" onchange="applyFilters()">
      <option value="">— Pilih —</option>
      <option value="skor_desc">Skor tertinggi → rendah</option>
      <option value="skor_asc">Skor terendah → tinggi</option>
      <option value="umur_desc">Umur tertinggi → rendah</option>
      <option value="umur_asc">Umur terendah → tinggi</option>
      <option value="device_desc">Jam perangkat tertinggi → rendah</option>
      <option value="device_asc">Jam perangkat terendah → tinggi</option>
      <option value="sleep_desc">Jam tidur terbanyak → sedikit</option>
      <option value="sleep_asc">Jam tidur terendah → tinggi</option>
      <option value="anxiety_desc">Kecemasan tertinggi → rendah</option>
      <option value="anxiety_asc">Kecemasan terendah → tinggi</option>
    </select>
  </div>

  <div class="table-container">
    <table id="mainTable">
      <thead>
        <tr>
          <th>No</th>
          <th>ID</th>
          <th>Skor Ketergantungan</th>
          <th>Kategori</th>
          <th>Gender</th>
          <th>Umur</th>
          <th>Region</th>
          <th>Tingkat Pendidikan</th>
          <th>Peran Harian</th>
          <th>Tingkat Pendapatan</th>
          <th>Jam Pakai Perangkat/Hari</th>
          <th>Buka HP/Hari</th>
          <th>Notifikasi/Hari</th>
          <th>Menit Medsos</th>
          <th>Menit Belajar</th>
          <th>Hari Aktif Fisik</th>
          <th>Jam Tidur</th>
          <th>Kualitas Tidur</th>
          <th>Skor Kecemasan</th>
          <th>Skor Depresi</th>
          <th>Tingkat Stres</th>
          <th>Skor Kebahagiaan</th>
          <th>Jenis Perangkat</th>
          <th>Status</th>
          <th>Rekomendasi</th>
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
            data-search="{{ strtolower($item['user_id'] . ' ' . $item['kategori'] . ' ' . $item['gender'] . ' ' . $item['region'] . ' ' . $item['peran_harian']) }}"
            data-gender="{{ $item['gender'] }}"
            data-region="{{ $item['region'] }}"
            data-kategori="{{ $item['kategori'] }}"
            data-role="{{ $item['peran_harian'] }}"
            data-skor="{{ $item['skor_ketergantungan'] }}"
            data-umur="{{ $item['umur'] }}"
            data-device="{{ $item['jam_perangkat_per_hari'] }}"
            data-sleep="{{ $item['jam_tidur'] }}"
            data-anxiety="{{ $item['skor_kecemasan'] }}"
          >
            <td>{{ $index + 1 }}</td>
            <td style="font-weight:600;color:var(--navy);">{{ $item['user_id'] }}</td>
            <td style="font-weight:700;color:var(--navy);">{{ $item['skor_ketergantungan'] }}</td>
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
             <button class="btn btn-ghost btn-sm" style="padding:5px 12px;font-size:11px;"
    onclick="showRekomendasi(this)"
    data-recs="{{ e(json_encode($item['rekomendasi'])) }}"
    data-uid="{{ $item['user_id'] }}">
    Lihat
</button>
            </td>
          </tr>
        @empty
          <tr>
            <td colspan="25">
              <div class="no-data">
                <div style="font-size:36px;margin-bottom:10px;">📋</div>
                <div style="font-size:13px;font-weight:600;margin-bottom:4px;">Belum ada data kuesioner</div>
                <div style="font-size:12px;">Kuesioner akan muncul di sini setelah user mulai mengisi</div>
              </div>
            </td>
          </tr>
        @endforelse
      </tbody>
    </table>
  </div>

  {{-- BOTTOM BAR --}}
  <div class="bottom-bar">
    <span class="count-info" id="countInfo">Menampilkan {{ count($kuesioner) }} data</span>
    <button class="btn-export" onclick="exportXlsx()">
      ⬇ Export data ke .xlsx
    </button>
  </div>
</div>

{{-- MODAL REKOMENDASI --}}
<div class="modal-overlay" id="modalOverlay" onclick="closeModal(event)">
  <div class="modal-box">
    <h3 id="modalTitle">Rekomendasi</h3>
    <div id="modalContent"></div>
    <button class="modal-close-btn" onclick="document.getElementById('modalOverlay').classList.remove('open')">Tutup</button>
  </div>
</div>

@push('scripts')
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<script>
  /* ── Filter & Sort ── */
  function applyFilters() {
    const search   = document.getElementById('searchInput').value.toLowerCase();
    const gender   = document.getElementById('fGender').value;
    const region   = document.getElementById('fRegion').value;
    const kategori = document.getElementById('fKategori').value;
    const role     = document.getElementById('fRole').value;
    const sort     = document.getElementById('sortBy').value;

    const tbody = document.getElementById('tableBody');
    let rows = Array.from(tbody.querySelectorAll('tr[data-search]'));

    // Filter
    rows.forEach(row => {
      const matchSearch   = !search   || row.dataset.search.includes(search);
      const matchGender   = !gender   || row.dataset.gender   === gender;
      const matchRegion   = !region   || row.dataset.region   === region;
      const matchKategori = !kategori || row.dataset.kategori === kategori;
      const matchRole     = !role     || row.dataset.role     === role;
      row.style.display = (matchSearch && matchGender && matchRegion && matchKategori && matchRole) ? '' : 'none';
    });

    // Sort
    if (sort) {
      const visibleRows = rows.filter(r => r.style.display !== 'none');
      const [field, dir] = sort.split('_');
      const key = { skor: 'skor', umur: 'umur', device: 'device', sleep: 'sleep', anxiety: 'anxiety' }[field];
      visibleRows.sort((a, b) => {
        const va = parseFloat(a.dataset[key]);
        const vb = parseFloat(b.dataset[key]);
        return dir === 'desc' ? vb - va : va - vb;
      });
      visibleRows.forEach(r => tbody.appendChild(r));
    }

    // Re-number
    let no = 1;
    rows.forEach(row => {
      if (row.style.display !== 'none') {
        row.querySelector('td:first-child').textContent = no++;
      }
    });

    // Count info
    const visible = rows.filter(r => r.style.display !== 'none').length;
    document.getElementById('countInfo').textContent = `Menampilkan ${visible} dari ${rows.length} data`;
  }

  function showRekomendasi(btn) {
    const recs = JSON.parse(btn.dataset.recs);
    const userId = btn.dataset.uid;
    document.getElementById('modalTitle').textContent = `Rekomendasi — ${userId}`;
    const content = document.getElementById('modalContent');
    content.innerHTML = recs.map(r =>
        `<div class="modal-rec-item"><div class="rec-dot"></div><div>${r}</div></div>`
    ).join('');
    document.getElementById('modalOverlay').classList.add('open');
}

  function closeModal(e) {
    if (e.target === document.getElementById('modalOverlay')) {
      document.getElementById('modalOverlay').classList.remove('open');
    }
  }

  /* ── Export XLSX ── */
  function exportXlsx() {
    const rows  = Array.from(document.querySelectorAll('#tableBody tr[data-search]'))
                       .filter(r => r.style.display !== 'none');
    const headers = [
      'No','ID User','Skor Ketergantungan','Kategori','Gender','Umur','Region',
      'Tingkat Pendidikan','Peran Harian','Tingkat Pendapatan',
      'Jam Perangkat/Hari','Buka HP/Hari','Notifikasi/Hari',
      'Menit Medsos','Menit Belajar','Hari Aktif Fisik',
      'Jam Tidur','Kualitas Tidur','Skor Kecemasan',
      'Skor Depresi','Tingkat Stres','Skor Kebahagiaan','Jenis Perangkat','Status'
    ];
    const data = [headers];
    rows.forEach(row => {
      const cells = Array.from(row.querySelectorAll('td'));
      // Ambil semua kolom kecuali kolom terakhir (Rekomendasi/tombol)
      data.push(cells.slice(0, cells.length - 1).map(td => td.textContent.trim()));
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