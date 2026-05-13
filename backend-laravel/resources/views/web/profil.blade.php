@extends('web.layouts.app')
@section('title', 'Profil')

@section('content')
@php $initials = strtoupper(substr($user->name ?? '?', 0, 2)); @endphp

<div style="max-width:700px;margin:0 auto;">
    {{-- Profile Hero --}}
    <div class="profile-hero anim-up">
        <div class="avatar avatar-xl" style="margin:0 auto 16px;position:relative;z-index:1;">{{ $initials }}</div>
        <h2 style="color:var(--text-primary);position:relative;z-index:1;">{{ $user->name }}</h2>
        <p style="color:var(--text-secondary);margin-top:4px;position:relative;z-index:1;">{{ $user->email }}</p>
        <div class="profile-tags">
            @if($user->age)<div class="tag">🎂 {{ $user->age }} tahun</div>@endif
            @if($user->education_level)<div class="tag">🎓 {{ $user->education_level }}</div>@endif
            @if($user->region)<div class="tag">📍 {{ $user->region }}</div>@endif
            @if($user->gender)<div class="tag">{{ $user->gender === 'Laki-laki' ? '👨' : '👩' }} {{ $user->gender }}</div>@endif
        </div>
    </div>

    {{-- Edit Profile --}}
    <div class="settings-group anim-up d2">
        <div class="settings-title">Pengaturan Akun</div>
        <div class="settings-list">
            <div class="settings-item" onclick="document.getElementById('editModal').style.display='flex'">
                <div class="settings-icon" style="background:rgba(13,148,136,.08);"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--teal)" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></div>
                <div style="flex:1;"><div style="font-weight:700;">Edit Data Diri</div><div style="font-size:.8125rem;color:var(--text-muted);">Ubah nama, gender, region</div></div>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--text-disabled)" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
            </div>
            <div class="settings-item" onclick="document.getElementById('pwModal').style.display='flex'">
                <div class="settings-icon" style="background:rgba(59,130,246,.08);"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></div>
                <div style="flex:1;"><div style="font-weight:700;">Ganti Password</div><div style="font-size:.8125rem;color:var(--text-muted);">Perbarui kata sandi</div></div>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--text-disabled)" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
            </div>
        </div>
    </div>

    {{-- Logout --}}
    <div class="settings-group anim-up d3">
        <div class="settings-title">Lainnya</div>
        <div class="settings-list">
            <form method="POST" action="{{ url('/user/logout') }}">@csrf
            <button type="submit" class="settings-item" style="width:100%;border:none;cursor:pointer;background:none;">
                <div class="settings-icon" style="background:rgba(239,68,68,.08);"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--red)" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg></div>
                <div style="flex:1;text-align:left;"><div style="font-weight:700;color:var(--red);">Keluar</div><div style="font-size:.8125rem;color:var(--text-muted);">Logout dari akun</div></div>
            </button>
            </form>
        </div>
    </div>
</div>

{{-- Edit Modal --}}
<div class="modal-overlay" id="editModal" style="display:none;">
<div class="modal-box">
    <div class="modal-header"><h3>Edit Data Diri</h3><button onclick="document.getElementById('editModal').style.display='none'" style="background:none;border:none;font-size:1.25rem;cursor:pointer;color:var(--text-muted);">✕</button></div>
    <form method="POST" action="{{ url('/user/profil') }}">@csrf @method('PUT')
    <div class="modal-body" style="display:flex;flex-direction:column;gap:16px;">
        <div class="form-group"><label class="form-label">Nama</label><input name="name" class="form-input" value="{{ $user->name }}" required></div>
        <div class="form-group"><label class="form-label">Gender</label><select name="gender" class="form-input form-select" required><option value="Laki-laki" {{ $user->gender=='Laki-laki'?'selected':'' }}>Laki-laki</option><option value="Perempuan" {{ $user->gender=='Perempuan'?'selected':'' }}>Perempuan</option></select></div>
        <div class="form-group"><label class="form-label">Region</label><input name="region" class="form-input" value="{{ $user->region }}" required></div>
        <div class="form-group"><label class="form-label">Pendidikan</label><input name="education_level" class="form-input" value="{{ $user->education_level }}" required></div>
        <div class="form-group"><label class="form-label">Peran</label><input name="daily_role" class="form-input" value="{{ $user->daily_role }}" required></div>
    </div>
    <div class="modal-footer"><button type="submit" class="btn btn-primary">Simpan</button></div>
    </form>
</div>
</div>

{{-- Password Modal --}}
<div class="modal-overlay" id="pwModal" style="display:none;">
<div class="modal-box">
    <div class="modal-header"><h3>Ganti Password</h3><button onclick="document.getElementById('pwModal').style.display='none'" style="background:none;border:none;font-size:1.25rem;cursor:pointer;color:var(--text-muted);">✕</button></div>
    <form method="POST" action="{{ url('/user/profil/password') }}">@csrf
    <div class="modal-body" style="display:flex;flex-direction:column;gap:16px;">
        <div class="form-group"><label class="form-label">Password Lama</label><input name="old_password" type="password" class="form-input" required></div>
        <div class="form-group"><label class="form-label">Password Baru</label><input name="password" type="password" class="form-input" required></div>
        <div class="form-group"><label class="form-label">Konfirmasi</label><input name="password_confirmation" type="password" class="form-input" required></div>
    </div>
    <div class="modal-footer"><button type="submit" class="btn btn-primary">Simpan</button></div>
    </form>
</div>
</div>
@endsection
