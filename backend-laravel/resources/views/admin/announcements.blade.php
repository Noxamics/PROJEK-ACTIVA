{{--
═══════════════════════════════════════════════
resources/views/admin/announcements.blade.php
Announcements — Kelola pengumuman untuk user
═══════════════════════════════════════════════
--}}
@extends('layouts.app')
@section('title', 'Announcements — Activa')
@section('page-title', 'Announcements')

@push('styles')
<style>
/* ── Announcements Page ────────────────────────────────────── */
.ann-layout {
    display: grid;
    grid-template-columns: 380px 1fr;
    gap: 24px;
    align-items: start;
}

@media (max-width: 1024px) {
    .ann-layout { grid-template-columns: 1fr; }
}

/* ── Create Form ── */
.ann-form-card {
    background: #fff;
    border-radius: 14px;
    border: 1px solid #E4EEF6;
    box-shadow: 0 2px 8px rgba(30,58,95,0.07);
    padding: 24px;
    position: sticky;
    top: 88px;
}

.ann-form-title {
    font-size: 16px;
    font-weight: 700;
    color: #1E3A5F;
    font-family: 'DM Sans', sans-serif;
    margin-bottom: 4px;
}

.ann-form-sub {
    font-size: 12.5px;
    color: #6B8BAE;
    margin-bottom: 20px;
}

.ann-field {
    margin-bottom: 16px;
}

.ann-label {
    display: block;
    font-size: 12px;
    font-weight: 600;
    color: #4A6180;
    margin-bottom: 6px;
    font-family: 'DM Sans', sans-serif;
}

.ann-input,
.ann-textarea,
.ann-select {
    width: 100%;
    padding: 10px 14px;
    font-size: 13.5px;
    font-family: 'DM Sans', sans-serif;
    color: #1E3A5F;
    background: #F8FBFE;
    border: 1px solid #E4EEF6;
    border-radius: 10px;
    outline: none;
    transition: border-color 0.15s, box-shadow 0.15s;
}

.ann-input:focus,
.ann-textarea:focus,
.ann-select:focus {
    border-color: #0D9488;
    box-shadow: 0 0 0 3px rgba(13,148,136,0.10);
}

.ann-textarea {
    resize: vertical;
    min-height: 100px;
}

.ann-select {
    appearance: none;
    cursor: pointer;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%234A6180' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 12px center;
    padding-right: 36px;
}

.ann-submit {
    width: 100%;
    padding: 12px;
    background: #0D9488;
    color: #fff;
    border: none;
    border-radius: 10px;
    font-size: 14px;
    font-weight: 600;
    font-family: 'DM Sans', sans-serif;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    transition: background 0.15s, transform 0.1s;
}

.ann-submit:hover {
    background: #0A7A6F;
    transform: translateY(-1px);
}

.ann-submit:active {
    transform: translateY(0);
}

/* ── Announcements List ── */
.ann-list-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
}

.ann-list-title {
    font-size: 16px;
    font-weight: 700;
    color: #1E3A5F;
    font-family: 'DM Sans', sans-serif;
}

.ann-list-count {
    font-size: 12px;
    color: #6B8BAE;
    background: #F0F9FF;
    border: 1px solid #E4EEF6;
    padding: 4px 12px;
    border-radius: 20px;
    font-weight: 600;
}

.ann-list {
    display: flex;
    flex-direction: column;
    gap: 14px;
}

.ann-item {
    background: #fff;
    border-radius: 14px;
    border: 1px solid #E4EEF6;
    box-shadow: 0 2px 8px rgba(30,58,95,0.05);
    padding: 20px;
    transition: box-shadow 0.2s;
}

.ann-item:hover {
    box-shadow: 0 4px 16px rgba(30,58,95,0.10);
}

.ann-item-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 10px;
}

.ann-item-title {
    font-size: 15px;
    font-weight: 700;
    color: #1E3A5F;
    font-family: 'DM Sans', sans-serif;
    line-height: 1.4;
}

.ann-type-badge {
    flex-shrink: 0;
    font-size: 10px;
    font-weight: 700;
    padding: 4px 10px;
    border-radius: 20px;
    letter-spacing: 0.04em;
    text-transform: uppercase;
}

.ann-type-badge--info {
    background: rgba(13,148,136,0.10);
    color: #0D9488;
    border: 1px solid rgba(13,148,136,0.20);
}

.ann-type-badge--warning {
    background: rgba(217,119,6,0.10);
    color: #D97706;
    border: 1px solid rgba(217,119,6,0.20);
}

.ann-type-badge--update {
    background: rgba(30,58,95,0.08);
    color: #1E3A5F;
    border: 1px solid rgba(30,58,95,0.15);
}

.ann-item-content {
    font-size: 13.5px;
    color: #4A6180;
    line-height: 1.6;
    margin-bottom: 14px;
}

.ann-item-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.ann-item-meta {
    font-size: 11.5px;
    color: #8BA3BE;
    display: flex;
    align-items: center;
    gap: 6px;
}

.ann-delete-btn {
    background: none;
    border: 1px solid rgba(224,82,82,0.20);
    color: #E05252;
    font-size: 12px;
    font-weight: 600;
    font-family: 'DM Sans', sans-serif;
    padding: 6px 14px;
    border-radius: 8px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 5px;
    transition: background 0.15s, border-color 0.15s;
}

.ann-delete-btn:hover {
    background: rgba(224,82,82,0.08);
    border-color: rgba(224,82,82,0.40);
}

/* ── Empty State ── */
.ann-empty {
    text-align: center;
    padding: 48px 24px;
    background: #fff;
    border-radius: 14px;
    border: 1px solid #E4EEF6;
}

.ann-empty-icon {
    color: #C8D8EA;
    margin-bottom: 12px;
}

.ann-empty-title {
    font-size: 15px;
    font-weight: 600;
    color: #4A6180;
    margin-bottom: 4px;
}

.ann-empty-sub {
    font-size: 12.5px;
    color: #8BA3BE;
}

/* ── Validation Error ── */
.ann-error {
    font-size: 12px;
    color: #E05252;
    margin-top: 4px;
}
</style>
@endpush

@section('content')

    <div class="ann-layout">

        {{-- ═══ Left: Create Form ═══ --}}
        <div class="ann-form-card">
            <div class="ann-form-title">Buat Pengumuman</div>
            <div class="ann-form-sub">Tulis pengumuman baru untuk pengguna aplikasi</div>

            <form method="POST" action="{{ route('admin.announcements.store') }}">
                @csrf

                <div class="ann-field">
                    <label class="ann-label">Judul</label>
                    <input type="text" name="title" class="ann-input"
                           placeholder="Contoh: Maintenance Terjadwal"
                           value="{{ old('title') }}" required>
                    @error('title')
                        <div class="ann-error">{{ $message }}</div>
                    @enderror
                </div>

                <div class="ann-field">
                    <label class="ann-label">Tipe</label>
                    <select name="type" class="ann-select" required>
                        <option value="info" {{ old('type') === 'info' ? 'selected' : '' }}>Informasi</option>
                        <option value="update" {{ old('type') === 'update' ? 'selected' : '' }}>Update</option>
                        <option value="warning" {{ old('type') === 'warning' ? 'selected' : '' }}>Peringatan</option>
                    </select>
                </div>

                <div class="ann-field">
                    <label class="ann-label">Isi Pengumuman</label>
                    <textarea name="content" class="ann-textarea"
                              placeholder="Tulis isi pengumuman di sini..."
                              required>{{ old('content') }}</textarea>
                    @error('content')
                        <div class="ann-error">{{ $message }}</div>
                    @enderror
                </div>

                <button type="submit" class="ann-submit">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Publikasikan
                </button>
            </form>
        </div>

        {{-- ═══ Right: List ═══ --}}
        <div>
            <div class="ann-list-header">
                <div class="ann-list-title">Riwayat Pengumuman</div>
                <div class="ann-list-count">{{ count($announcements) }} total</div>
            </div>

            @if(count($announcements) > 0)
                <div class="ann-list">
                    @foreach($announcements as $ann)
                        <div class="ann-item">
                            <div class="ann-item-top">
                                <div class="ann-item-title">{{ $ann['title'] }}</div>
                                <span class="ann-type-badge ann-type-badge--{{ $ann['type'] }}">
                                    {{ $ann['type'] === 'info' ? 'Informasi' : ($ann['type'] === 'warning' ? 'Peringatan' : 'Update') }}
                                </span>
                            </div>
                            <div class="ann-item-content">{{ $ann['content'] }}</div>
                            <div class="ann-item-footer">
                                <div class="ann-item-meta">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                    {{ $ann['created_at_formatted'] }} · {{ $ann['author'] ?? 'Admin' }}
                                </div>
                                <form method="POST" action="{{ route('admin.announcements.destroy', $ann['_id']) }}"
                                      onsubmit="return confirm('Hapus pengumuman ini?')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="ann-delete-btn">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                        Hapus
                                    </button>
                                </form>
                            </div>
                        </div>
                    @endforeach
                </div>
            @else
                <div class="ann-empty">
                    <div class="ann-empty-icon">
                        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                    </div>
                    <div class="ann-empty-title">Belum ada pengumuman</div>
                    <div class="ann-empty-sub">Buat pengumuman pertama menggunakan form di samping</div>
                </div>
            @endif
        </div>

    </div>

@endsection
