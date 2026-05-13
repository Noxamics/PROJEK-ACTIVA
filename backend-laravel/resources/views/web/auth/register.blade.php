<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daftar — ACTIVA</title>
    <link href="{{ asset('css/web.css') }}" rel="stylesheet">
</head>
<body>
<div class="auth-page">
    <div class="auth-left">
        <div class="auth-form-container anim-fade">
            <div style="margin-bottom:28px;">
                <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
                    <div class="sidebar-logo"><svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round"><path d="M9 11l3 3L22 4"/></svg></div>
                    <div><div style="color:var(--text-primary);font-size:1.25rem;font-weight:800;">ACTIVA</div></div>
                </div>
                <h1 style="color:var(--text-primary);margin-bottom:8px;">Buat Akun</h1>
                <p style="color:var(--text-secondary);font-size:.9375rem;">Lengkapi data diri untuk membuat akun baru</p>
            </div>

            @if($errors->any())
                <div style="padding:12px 16px;background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.2);border-radius:var(--radius-md);margin-bottom:20px;">
                    @foreach($errors->all() as $err)
                        <p style="color:var(--red);font-size:.875rem;font-weight:500;">{{ $err }}</p>
                    @endforeach
                </div>
            @endif

            <form method="POST" action="{{ url('/user/register') }}" style="display:flex;flex-direction:column;gap:16px;">
                @csrf
                {{-- Step 1: Data Diri --}}
                <div style="font-size:.75rem;font-weight:700;color:var(--teal);letter-spacing:.08em;text-transform:uppercase;margin-bottom:4px;">DATA DIRI</div>
                <div class="form-group"><label class="form-label form-label-dark">Nama Lengkap</label><input name="name" class="form-input form-input-dark" placeholder="John Doe" value="{{ old('name') }}" required></div>
                <div class="form-group"><label class="form-label form-label-dark">Email</label><input name="email" type="email" class="form-input form-input-dark" placeholder="email@example.com" value="{{ old('email') }}" required></div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                    <div class="form-group"><label class="form-label form-label-dark">Password</label><input name="password" type="password" class="form-input form-input-dark" placeholder="min. 6 karakter" required></div>
                    <div class="form-group"><label class="form-label form-label-dark">Konfirmasi</label><input name="password_confirmation" type="password" class="form-input form-input-dark" placeholder="ulangi password" required></div>
                </div>

                <div style="height:1px;background:var(--border-card);margin:8px 0;"></div>

                {{-- Step 2: Demografi --}}
                <div style="font-size:.75rem;font-weight:700;color:var(--teal);letter-spacing:.08em;text-transform:uppercase;margin-bottom:4px;">DEMOGRAFI</div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                    <div class="form-group"><label class="form-label form-label-dark">Jenis Kelamin</label>
                        <select name="gender" class="form-input form-input-dark form-select" required><option value="">Pilih</option><option value="Laki-laki" {{ old('gender')=='Laki-laki'?'selected':'' }}>Laki-laki</option><option value="Perempuan" {{ old('gender')=='Perempuan'?'selected':'' }}>Perempuan</option></select></div>
                    <div class="form-group"><label class="form-label form-label-dark">Tanggal Lahir</label><input name="tgl_lahir" type="date" class="form-input form-input-dark" value="{{ old('tgl_lahir') }}" required></div>
                </div>
                <div class="form-group"><label class="form-label form-label-dark">Region</label>
                    <select name="region" class="form-input form-input-dark form-select" required><option value="">Pilih region</option>@foreach(['Jawa','Sumatera','Kalimantan','Sulawesi','Bali & Nusa Tenggara','Papua & Maluku'] as $r)<option value="{{ $r }}" {{ old('region')==$r?'selected':'' }}>{{ $r }}</option>@endforeach</select></div>

                <div style="height:1px;background:var(--border-card);margin:8px 0;"></div>

                {{-- Step 3: Pendidikan --}}
                <div style="font-size:.75rem;font-weight:700;color:var(--teal);letter-spacing:.08em;text-transform:uppercase;margin-bottom:4px;">PENDIDIKAN & PERAN</div>
                <div class="form-group"><label class="form-label form-label-dark">Pendidikan Terakhir</label>
                    <select name="education_level" class="form-input form-input-dark form-select" required><option value="">Pilih</option>@foreach(['SD','SMP','SMA/SMK','D3','S1','S2','S3'] as $e)<option value="{{ $e }}" {{ old('education_level')==$e?'selected':'' }}>{{ $e }}</option>@endforeach</select></div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                    <div class="form-group"><label class="form-label form-label-dark">Peran Harian</label>
                        <select name="daily_role" class="form-input form-input-dark form-select" required><option value="">Pilih</option>@foreach(['Pelajar','Mahasiswa','Pekerja','Wiraswasta','Lainnya'] as $r)<option value="{{ $r }}" {{ old('daily_role')==$r?'selected':'' }}>{{ $r }}</option>@endforeach</select></div>
                    <div class="form-group"><label class="form-label form-label-dark">Pendapatan</label>
                        <select name="income_level" class="form-input form-input-dark form-select" required><option value="">Pilih</option>@foreach(['< 1 Juta','1-3 Juta','3-5 Juta','5-10 Juta','> 10 Juta'] as $i)<option value="{{ $i }}" {{ old('income_level')==$i?'selected':'' }}>{{ $i }}</option>@endforeach</select></div>
                </div>

                <button type="submit" class="btn btn-primary btn-lg btn-block" style="margin-top:8px;">Daftar Sekarang</button>
            </form>

            <p style="color:var(--text-secondary);text-align:center;margin-top:24px;font-size:.875rem;">
                Sudah punya akun? <a href="{{ url('/user/login') }}" style="color:var(--teal);font-weight:700;">Masuk</a>
            </p>
        </div>
    </div>
    <div class="auth-right">
        <div class="auth-brand">
            <div style="width:80px;height:80px;margin:0 auto 28px;background:rgba(255,255,255,.1);border-radius:24px;display:flex;align-items:center;justify-content:center;">
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
            </div>
            <h2>Mulai Perjalananmu</h2>
            <p style="margin-top:12px;">Daftarkan dirimu dan mulai analisis kebiasaan digital secara personal.</p>
        </div>
    </div>
</div>
</body>
</html>
