{{--
═══════════════════════════════════════════════
resources/views/admin/export.blade.php
Export Center — Download data dalam format CSV
═══════════════════════════════════════════════
--}}
@extends('layouts.app')
@section('title', 'Export Center — Activa')
@section('page-title', 'Export Center')

@push('styles')
<style>
/* ── Export Center ──────────────────────────────────────────── */
.export-hero {
    background: linear-gradient(135deg, #1E3A5F 0%, #264875 100%);
    border-radius: 16px;
    padding: 32px 36px;
    color: #fff;
    margin-bottom: 28px;
    position: relative;
    overflow: hidden;
}

.export-hero::after {
    content: '';
    position: absolute;
    top: -30px;
    right: -30px;
    width: 160px;
    height: 160px;
    background: radial-gradient(circle, rgba(13,148,136,0.20) 0%, transparent 70%);
    border-radius: 50%;
    pointer-events: none;
}

.export-hero-title {
    font-family: 'DM Serif Display', serif;
    font-size: 24px;
    margin-bottom: 6px;
}

.export-hero-sub {
    font-size: 13.5px;
    color: rgba(255,255,255,0.65);
    line-height: 1.5;
    max-width: 520px;
}

.export-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 28px;
}

@media (max-width: 768px) {
    .export-grid { grid-template-columns: 1fr; }
}

.export-card {
    background: #fff;
    border-radius: 14px;
    border: 1px solid #E4EEF6;
    box-shadow: 0 2px 8px rgba(30,58,95,0.07);
    padding: 0;
    overflow: hidden;
    transition: box-shadow 0.2s, transform 0.2s;
}

.export-card:hover {
    box-shadow: 0 6px 24px rgba(30,58,95,0.12);
    transform: translateY(-2px);
}

.export-card-top {
    padding: 24px 24px 18px;
}

.export-card-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 16px;
}

.export-card-icon--users {
    background: rgba(13,148,136,0.10);
    color: #0D9488;
}

.export-card-icon--kuesioner {
    background: rgba(30,58,95,0.08);
    color: #1E3A5F;
}

.export-card-title {
    font-size: 17px;
    font-weight: 700;
    color: #1E3A5F;
    font-family: 'DM Sans', sans-serif;
    margin-bottom: 4px;
}

.export-card-desc {
    font-size: 13px;
    color: #6B8BAE;
    line-height: 1.5;
    margin-bottom: 16px;
}

.export-card-stat {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: #F0F9FF;
    border: 1px solid #E4EEF6;
    border-radius: 8px;
    padding: 6px 12px;
    font-size: 13px;
    font-weight: 600;
    color: #1E3A5F;
    margin-bottom: 16px;
}

.export-card-stat-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #0D9488;
}

.export-card-columns {
    font-size: 12px;
    color: #6B8BAE;
    line-height: 1.6;
    margin-bottom: 0;
}

.export-card-columns strong {
    color: #4A6180;
    font-weight: 600;
}

.export-card-bottom {
    padding: 16px 24px;
    background: #F8FBFE;
    border-top: 1px solid #E4EEF6;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.export-card-format {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 12px;
    color: #6B8BAE;
    font-weight: 500;
}

.export-card-format-badge {
    background: rgba(13,148,136,0.10);
    color: #0D9488;
    font-size: 10px;
    font-weight: 700;
    padding: 3px 8px;
    border-radius: 6px;
    letter-spacing: 0.05em;
}

.export-btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 9px 20px;
    background: #1E3A5F;
    color: #fff;
    border: none;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 600;
    font-family: 'DM Sans', sans-serif;
    cursor: pointer;
    text-decoration: none;
    transition: background 0.15s, transform 0.1s;
}

.export-btn:hover {
    background: #264875;
    transform: translateY(-1px);
}

.export-btn:active {
    transform: translateY(0);
}

.export-btn svg {
    flex-shrink: 0;
}

/* ── Info Banner ── */
.export-info {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    background: rgba(13,148,136,0.06);
    border: 1px solid rgba(13,148,136,0.18);
    border-radius: 12px;
    padding: 16px 20px;
    font-size: 13px;
    color: #2D4A6A;
    line-height: 1.6;
}

.export-info-icon {
    flex-shrink: 0;
    color: #0D9488;
    margin-top: 1px;
}
</style>
@endpush

@section('content')

    {{-- Hero Banner --}}
    <div class="export-hero">
        <div class="export-hero-title">Export Center</div>
        <div class="export-hero-sub">
            Download data analitik dalam format CSV untuk kebutuhan laporan, riset, atau dokumentasi.
            Semua data diekspor secara anonim tanpa informasi identitas personal.
        </div>
    </div>

    {{-- Export Cards --}}
    <div class="export-grid">

        {{-- Card: Data Users --}}
        <div class="export-card">
            <div class="export-card-top">
                <div class="export-card-icon export-card-icon--users">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                </div>
                <div class="export-card-title">Data Pengguna</div>
                <div class="export-card-desc">Ekspor data demografis pengguna terdaftar termasuk profil, wilayah, dan informasi pendidikan.</div>
                <div class="export-card-stat">
                    <span class="export-card-stat-dot"></span>
                    {{ $userCount }} pengguna terdaftar
                </div>
                <div class="export-card-columns">
                    <strong>Kolom:</strong> Nama, Email, Gender, Umur, Region, Pendidikan, Peran, Pendapatan, Tanggal Daftar
                </div>
            </div>
            <div class="export-card-bottom">
                <div class="export-card-format">
                    Format: <span class="export-card-format-badge">CSV</span>
                </div>
                <a href="{{ route('admin.export.download', ['type' => 'users']) }}" class="export-btn">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    Download
                </a>
            </div>
        </div>

        {{-- Card: Data Kuesioner --}}
        <div class="export-card">
            <div class="export-card-top">
                <div class="export-card-icon export-card-icon--kuesioner">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                </div>
                <div class="export-card-title">Data Kuesioner & ML</div>
                <div class="export-card-desc">Ekspor hasil kuesioner lengkap beserta skor prediksi Machine Learning dan kategori ketergantungan.</div>
                <div class="export-card-stat">
                    <span class="export-card-stat-dot"></span>
                    {{ $kuesionerCount }} kuesioner terisi
                </div>
                <div class="export-card-columns">
                    <strong>Kolom:</strong> Skor, Kategori, Jam Perangkat, Buka HP, Notifikasi, Medsos, Belajar, Aktivitas Fisik, Tidur, Kecemasan, Depresi, Stres, Kebahagiaan
                </div>
            </div>
            <div class="export-card-bottom">
                <div class="export-card-format">
                    Format: <span class="export-card-format-badge">CSV</span>
                </div>
                <a href="{{ route('admin.export.download', ['type' => 'kuesioner']) }}" class="export-btn">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    Download
                </a>
            </div>
        </div>

    </div>

    {{-- Info Banner --}}
    <div class="export-info">
        <div class="export-info-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        </div>
        <div>
            <strong>Catatan Privasi:</strong> File yang diekspor menggunakan ID anonim. untuk menjaga privasi pengguna. Data hanya digunakan untuk keperluan analisis dan laporan internal.
        </div>
    </div>

@endsection
