@extends('web.layouts.app')
@section('title', 'Profil')

@section('styles')
<link href="{{ asset('css/user-web/profile.css') }}" rel="stylesheet">
@endsection

@section('content')
@php
    $initials = strtoupper(substr($user->name ?? '?', 0, 2));
    $dots = [
        [10,15],[25,70],[60,30],[82,62],[90,20],[6,88],[44,90],[70,12],[36,52],[78,80],
        [18,42],[50,6],[88,48],[14,66],[65,85],[38,28],[96,38],[4,28],[74,56],[22,78],
    ];
@endphp

<script>document.body.classList.add('page-profil');</script>

{{-- Page-level glow blobs --}}
<div class="profil-page-glow" aria-hidden="true">
    <span class="g1"></span>
    <span class="g2"></span>
</div>

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
                <select name="gender" class="profil-form-input profil-form-select" required>
                    <option value="Laki-laki" {{ $user->gender=='Laki-laki'?'selected':'' }}>Laki-laki</option>
                    <option value="Perempuan" {{ $user->gender=='Perempuan'?'selected':'' }}>Perempuan</option>
                </select>
            </div>
            <div class="profil-form-group">
                <label class="profil-form-label">Region / Kota</label>
                <input name="region" class="profil-form-input" value="{{ $user->region }}" placeholder="Contoh: Surabaya" required>
            </div>
            <div class="profil-form-group">
                <label class="profil-form-label">Pendidikan Terakhir</label>
                <input name="education_level" class="profil-form-input" value="{{ $user->education_level }}" placeholder="Contoh: Sarjana" required>
            </div>
            <div class="profil-form-group">
                <label class="profil-form-label">Peran Sehari-hari</label>
                <input name="daily_role" class="profil-form-input" value="{{ $user->daily_role }}" placeholder="Contoh: Mahasiswa" required>
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
<script>document.body.classList.add('page-profil');</script>
@endsection