@extends('web.layouts.app')
@section('title', 'Profil')

@section('styles')
@section('body-class', 'page-histori')
<link href="{{ asset('css/user-web/histori.css') }}" rel="stylesheet">
<link href="{{ asset('css/user-web/profile.css') }}" rel="stylesheet">
<style>
    /* Override profile.css specifically for dark theme and glassmorphism */
    body.page-profil, body.page-histori {
        background: transparent !important; 
    }
    .profil-hero {
        background: rgba(255,255,255,0.04) !important;
        border: 1px solid rgba(255,255,255,0.1) !important;
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
    }
    .profil-card {
        background: rgba(255,255,255,0.06) !important;
        border: 1px solid rgba(255,255,255,0.1) !important;
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
    }
    .profil-item {
        border-bottom: 1px solid rgba(255,255,255,0.08) !important;
        transition: transform 0.25s cubic-bezier(0.4,0,0.2,1), background 0.25s, box-shadow 0.25s, border-color 0.25s !important;
    }
    .profil-item:last-child {
        border-bottom: none !important;
    }
    .profil-item:hover {
        background: rgba(255,255,255,0.08) !important;
        transform: translateY(-4px);
        box-shadow: 0 12px 40px rgba(0,229,200,0.15), 0 4px 12px rgba(0,0,0,0.3) !important;
        border-radius: 12px;
        border: 1px solid rgba(0,229,200,0.4) !important;
    }
    .profil-item-label { color: #fff !important; }
    .profil-item-label.danger { color: #ef4444 !important; }
    .profil-item-desc { color: rgba(255,255,255,0.6) !important; }
    .profil-item-chevron { stroke: rgba(255,255,255,0.4) !important; }
    
    /* Title in right panel */
    .profil-section-title { color: rgba(255,255,255,0.55) !important; }
    
    /* Modal dark theme */
    .profil-modal-box {
        background: rgba(15,23,42,0.95) !important;
        border: 1px solid rgba(255,255,255,0.1) !important;
        backdrop-filter: blur(16px);
        color: #fff;
    }
    .profil-modal-header { border-bottom-color: rgba(255,255,255,0.08) !important; }
    .profil-modal-header h3 { color: #fff !important; }
    .profil-form-label { color: rgba(255,255,255,0.7) !important; }
    .profil-form-input {
        background: rgba(255,255,255,0.05) !important;
        border: 1px solid rgba(255,255,255,0.1) !important;
        color: #fff !important;
    }
    .profil-form-input:focus { border-color: #0D9488 !important; }
    .profil-modal-close {
        background: rgba(255,255,255,0.08) !important;
        color: rgba(255,255,255,0.6) !important;
    }
    .btn-profil-ghost {
        background: rgba(255,255,255,0.08) !important;
        border-color: rgba(255,255,255,0.1) !important;
        color: #fff !important;
    }

    /* Custom Dropdown (Dark Theme) */
    .cdd-wrap { position: relative; }
    .cdd {
        display: flex; align-items: center; justify-content: space-between;
        width: 100%; padding: 13px 16px;
        background: rgba(255,255,255,0.05) !important;
        border: 1px solid rgba(255,255,255,0.1) !important;
        border-radius: 12px; color: #fff;
        font-size: .9375rem; cursor: pointer; transition: all .2s;
    }
    .cdd:hover, .cdd.open { border-color: #0D9488 !important; }
    .cdd.open .cdd-arrow { transform: rotate(180deg); }
    .cdd-arrow { transition: transform 0.2s; stroke: rgba(255,255,255,0.4); }
    .cdd-menu {
        position: absolute; top: calc(100% + 6px); left: 0; right: 0;
        background: rgba(15,23,42,0.98); border: 1px solid rgba(255,255,255,0.1);
        border-radius: 12px; padding: 6px; z-index: 100;
        box-shadow: 0 12px 40px rgba(0,0,0,0.5);
        opacity: 0; visibility: hidden; transform: translateY(-10px);
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        max-height: 200px; overflow-y: auto;
    }
    .cdd-menu.open { opacity: 1; visibility: visible; transform: translateY(0); }
    .cdd-item {
        padding: 10px 14px; border-radius: 8px; color: rgba(255,255,255,0.8);
        font-size: .9375rem; cursor: pointer; transition: all .15s;
    }
    .cdd-item:hover { background: rgba(255,255,255,0.08); color: #fff; }
    .cdd-item.selected { background: rgba(13,148,136,0.15); color: #14B8A6; font-weight: 600; }
</style>
@endsection

@section('content')
@php
    $initials = strtoupper(substr($user->name ?? '?', 0, 2));
    $dots = [
        [10,15],[25,70],[60,30],[82,62],[90,20],[6,88],[44,90],[70,12],[36,52],[78,80],
        [18,42],[50,6],[88,48],[14,66],[65,85],[38,28],[96,38],[4,28],[74,56],[22,78],
    ];
@endphp

{{-- ── Dark background + decorative circles ── --}}
<div class="hist-bg"       aria-hidden="true"></div>
<div class="hist-orb-mid"  aria-hidden="true"></div>
<div class="hist-circle-1" aria-hidden="true"></div>
<div class="hist-circle-2" aria-hidden="true"></div>
<div class="hist-circle-3" aria-hidden="true"></div>
<div class="hist-circle-4" aria-hidden="true"></div>
<div class="hist-circle-5" aria-hidden="true"></div>
<div class="hist-circle-6" aria-hidden="true"></div>

<div class="profil-wrapper">
<div class="profil-layout">

    {{-- ═══════════════════════════════
         LEFT — HERO CARD
    ═══════════════════════════════ --}}
    <div class="profil-hero">
        <div class="profil-hero-bg">
            <div class="hero-grid"></div>
            <div class="hero-orb hero-orb-1"></div>
            <div class="hero-orb hero-orb-2"></div>
            <div class="hero-orb hero-orb-3"></div>
            <div class="hero-ring hero-ring-1"></div>
            <div class="hero-ring hero-ring-2"></div>
            <div class="hero-ring hero-ring-3"></div>
            <div class="hero-particles">
                @foreach($dots as $i => $dot)
                <div class="hero-dot" style="left:{{ $dot[0] }}%;top:{{ $dot[1] }}%;animation-delay:{{ $i*0.28 }}s;width:{{ 2+($i%3) }}px;height:{{ 2+($i%3) }}px;"></div>
                @endforeach
            </div>
        </div>

        {{-- Avatar --}}
        <div class="profil-avatar-wrap">
            <div class="profil-avatar-glow"></div>
            <div class="profil-avatar-ring"></div>
            <div class="profil-avatar">{{ $initials }}</div>
        </div>

        {{-- Name & email --}}
        <div class="profil-name">{{ $user->name }}</div>
        <div class="profil-email">{{ $user->email }}</div>

        {{-- Role badge --}}
        @if($user->daily_role)
        <div style="display:flex;justify-content:center;">
            <div class="profil-role-badge">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                {{ $user->daily_role }}
            </div>
        </div>
        @endif

        {{-- Info tags --}}
        <div class="profil-tags">
            @if($user->age)
            <div class="profil-tag">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                {{ $user->age }} Tahun
            </div>
            @endif
            @if($user->education_level)
            <div class="profil-tag">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
                {{ $user->education_level }}
            </div>
            @endif
            @if($user->region)
            <div class="profil-tag">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                {{ $user->region }}
            </div>
            @endif
            @if($user->gender)
            <div class="profil-tag">
                @if($user->gender === 'Laki-laki')
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="10" cy="14" r="5"/><line x1="19" y1="5" x2="14.14" y2="9.86"/><polyline points="15 5 19 5 19 9"/></svg>
                @else
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="5"/><line x1="12" y1="13" x2="12" y2="21"/><line x1="9" y1="18" x2="15" y2="18"/></svg>
                @endif
                {{ $user->gender }}
            </div>
            @endif
        </div>

        {{-- Maskot --}}
        {{-- <img src="{{ asset('images/Maskot2.png') }}" alt="" class="profil-maskot"
             onerror="this.style.display='none'"> --}}
    </div>{{-- /profil-hero --}}


    {{-- ═══════════════════════════════
         RIGHT — SETTINGS
    ═══════════════════════════════ --}}
    <div class="profil-right">

        {{-- Pengaturan Akun --}}
        <div>
            <div class="profil-section-title">Pengaturan Akun</div>
            <div class="profil-card">

                {{-- Edit Data Diri --}}
                <div class="profil-item" onclick="document.getElementById('editModal').style.display='flex'">
                    <div class="profil-item-icon teal">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#0D9488" stroke-width="2">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>
                        </svg>
                    </div>
                    <div class="profil-item-body">
                        <div class="profil-item-label">Edit Data Diri</div>
                        <div class="profil-item-desc">Ubah nama, gender, region & pendidikan</div>
                    </div>
                    <svg class="profil-item-chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
                </div>

                {{-- Ganti Password --}}
                <div class="profil-item" onclick="document.getElementById('pwModal').style.display='flex'">
                    <div class="profil-item-icon blue">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2">
                            <rect x="3" y="11" width="18" height="11" rx="2"/>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        </svg>
                    </div>
                    <div class="profil-item-body">
                        <div class="profil-item-label">Ganti Password</div>
                        <div class="profil-item-desc">Perbarui kata sandi akun</div>
                    </div>
                    <svg class="profil-item-chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
                </div>

            </div>
        </div>

        {{-- Lainnya --}}
        <div>
            <div class="profil-section-title">Lainnya</div>
            <div class="profil-card">
                <form method="POST" action="{{ url('/user/logout') }}" style="display:contents;">
                    @csrf
                    <button type="submit" class="profil-item">
                        <div class="profil-item-icon red">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#EF4444" stroke-width="2">
                                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                                <polyline points="16 17 21 12 16 7"/>
                                <line x1="21" y1="12" x2="9" y2="12"/>
                            </svg>
                        </div>
                        <div class="profil-item-body">
                            <div class="profil-item-label danger">Keluar</div>
                            <div class="profil-item-desc">Logout dari akun Anda</div>
                        </div>
                        <svg class="profil-item-chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#EF4444" stroke-width="2" style="opacity:.35;"><polyline points="9 18 15 12 9 6"/></svg>
                    </button>
                </form>
            </div>
        </div>

    </div>{{-- /profil-right --}}

</div>{{-- /profil-layout --}}
</div>{{-- /profil-wrapper --}}


{{-- ═══ MODAL EDIT DATA DIRI ═══ --}}
<div class="profil-modal-overlay" id="editModal" style="display:none;" onclick="if(event.target===this)this.style.display='none'">
    <div class="profil-modal-box">
        <div class="profil-modal-header">
            <h3>Edit Data Diri</h3>
            <button class="profil-modal-close" onclick="document.getElementById('editModal').style.display='none'" type="button">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>
        <form method="POST" action="{{ url('/user/profil') }}">@csrf @method('PUT')
        <div class="profil-modal-body">
            <div class="profil-form-group">
                <label class="profil-form-label">Nama Lengkap</label>
                <input name="name" class="profil-form-input" value="{{ $user->name }}" placeholder="Nama lengkap" required>
            </div>
            
            <div class="profil-form-group">
                <label class="profil-form-label">Gender</label>
                <input type="hidden" name="gender" id="val-gender" value="{{ $user->gender }}" required>
                <div class="cdd-wrap">
                    <div class="cdd" id="dd-gender" onclick="toggleDD('gender')">
                        <span id="lbl-gender">{{ $user->gender ?: 'Pilih jenis kelamin' }}</span>
                        <svg class="cdd-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
                    </div>
                    <div class="cdd-menu" id="menu-gender">
                        <div class="cdd-item {{ $user->gender=='Laki-laki' ? 'selected' : '' }}" onclick="pickDD('gender','Laki-laki','Laki-laki')">Laki-laki</div>
                        <div class="cdd-item {{ $user->gender=='Perempuan' ? 'selected' : '' }}" onclick="pickDD('gender','Perempuan','Perempuan')">Perempuan</div>
                    </div>
                </div>
            </div>
            
            <div class="profil-form-group">
                <label class="profil-form-label">Region / Wilayah</label>
                <input type="hidden" name="region" id="val-region" value="{{ $user->region }}" required>
                <div class="cdd-wrap">
                    <div class="cdd" id="dd-region" onclick="toggleDD('region')">
                        <span id="lbl-region">{{ $user->region ?: 'Pilih wilayah' }}</span>
                        <svg class="cdd-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
                    </div>
                    <div class="cdd-menu" id="menu-region">
                        @foreach(['Afrika', 'Asia', 'Eropa', 'Timur Tengah', 'Amerika Utara', 'Amerika Selatan'] as $r)
                        <div class="cdd-item {{ $user->region == $r ? 'selected' : '' }}" onclick="pickDD('region','{{ $r }}','{{ $r }}')">{{ $r }}</div>
                        @endforeach
                    </div>
                </div>
            </div>
            
            <div class="profil-form-group">
                <label class="profil-form-label">Pendidikan Terakhir</label>
                <input type="hidden" name="education_level" id="val-education_level" value="{{ $user->education_level }}" required>
                <div class="cdd-wrap">
                    <div class="cdd" id="dd-education_level" onclick="toggleDD('education_level')">
                        <span id="lbl-education_level">{{ $user->education_level ?: 'Pilih pendidikan' }}</span>
                        <svg class="cdd-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
                    </div>
                    <div class="cdd-menu" id="menu-education_level">
                        @foreach(['SMA/SMK/Sederajat', 'Sarjana', 'Magister', 'Doktor'] as $e)
                        <div class="cdd-item {{ $user->education_level == $e ? 'selected' : '' }}" onclick="pickDD('education_level','{{ $e }}','{{ $e }}')">{{ $e }}</div>
                        @endforeach
                    </div>
                </div>
            </div>
            
            <div class="profil-form-group">
                <label class="profil-form-label">Peran Sehari-hari</label>
                <input type="hidden" name="daily_role" id="val-daily_role" value="{{ $user->daily_role }}" required>
                <div class="cdd-wrap">
                    <div class="cdd" id="dd-daily_role" onclick="toggleDD('daily_role')">
                        <span id="lbl-daily_role">{{ $user->daily_role ?: 'Pilih peran' }}</span>
                        <svg class="cdd-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
                    </div>
                    <div class="cdd-menu" id="menu-daily_role">
                        @foreach(['Pelajar/Mahasiswa', 'Karyawan Penuh Waktu', 'Karyawan Paruh Waktu', 'Pengurus Rumah Tangga', 'Tidak Bekerja'] as $r)
                        <div class="cdd-item {{ $user->daily_role == $r ? 'selected' : '' }}" onclick="pickDD('daily_role','{{ $r }}','{{ $r }}')">{{ $r }}</div>
                        @endforeach
                    </div>
                </div>
            </div>
        </div>
        <div class="profil-modal-footer">
            <button type="button" class="btn-profil-ghost" onclick="document.getElementById('editModal').style.display='none'">Batal</button>
            <button type="submit" class="btn-profil-primary">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                Simpan
            </button>
        </div>
        </form>
    </div>
</div>

{{-- ═══ MODAL GANTI PASSWORD ═══ --}}
<div class="profil-modal-overlay" id="pwModal" style="display:none;" onclick="if(event.target===this)this.style.display='none'">
    <div class="profil-modal-box">
        <div class="profil-modal-header">
            <h3>Ganti Password</h3>
            <button class="profil-modal-close" onclick="document.getElementById('pwModal').style.display='none'" type="button">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>
        <form method="POST" action="{{ url('/user/profil/password') }}">@csrf
        <div class="profil-modal-body">
            <div class="profil-form-group">
                <label class="profil-form-label">Password Lama</label>
                <input name="old_password" type="password" class="profil-form-input" placeholder="Masukkan password lama" required>
            </div>
            <div class="profil-form-group">
                <label class="profil-form-label">Password Baru</label>
                <input name="password" type="password" class="profil-form-input" placeholder="Minimal 8 karakter" required>
            </div>
            <div class="profil-form-group">
                <label class="profil-form-label">Konfirmasi Password Baru</label>
                <input name="password_confirmation" type="password" class="profil-form-input" placeholder="Ulangi password baru" required>
            </div>
        </div>
        <div class="profil-modal-footer">
            <button type="button" class="btn-profil-ghost" onclick="document.getElementById('pwModal').style.display='none'">Batal</button>
            <button type="submit" class="btn-profil-primary">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                Perbarui
            </button>
        </div>
        </form>
    </div>
</div>

@endsection

@section('scripts')
<script>
    document.body.classList.add('page-histori');

    function toggleDD(name) {
        const menu = document.getElementById('menu-' + name);
        const btn  = document.getElementById('dd-' + name);
        const isOpen = menu.classList.contains('open');
        closeAllDD();
        if (!isOpen) { 
            menu.classList.add('open'); 
            btn.classList.add('open'); 
        }
    }
    
    function pickDD(name, value, label) {
        document.getElementById('val-' + name).value = value;
        const lbl = document.getElementById('lbl-' + name);
        lbl.textContent = label;
        
        document.querySelectorAll('#menu-' + name + ' .cdd-item').forEach(el => {
            if(el.textContent.trim() === label) {
                el.classList.add('selected');
            } else {
                el.classList.remove('selected');
            }
        });
        closeAllDD();
    }
    
    function closeAllDD() {
        document.querySelectorAll('.cdd-menu').forEach(m => m.classList.remove('open'));
        document.querySelectorAll('.cdd').forEach(b => b.classList.remove('open'));
    }
    
    document.addEventListener('click', e => {
        if (!e.target.closest('.profil-form-group') && !e.target.closest('.cdd-wrap')) {
            closeAllDD();
        }
    });
</script>
@endsection