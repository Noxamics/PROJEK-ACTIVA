<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daftar — ACTIVA</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="{{ asset('css/user-web/register.css') }}" rel="stylesheet">
</head>
<body>

    {{-- ══════════════════════════════════════════
         KIRI — Branding sticky (dark navy)
    ══════════════════════════════════════════ --}}
    <div class="auth-left">

        <div class="deco-circle deco-circle-1"></div>
        <div class="deco-circle deco-circle-2"></div>
        <div class="deco-circle deco-circle-3"></div>

        <div class="auth-brand">

            {{-- Logo --}}
            <div class="logo-row">
                <img src="{{ asset('images/NewLogoEmblem2.svg') }}"
                     alt="ACTIVA" class="logo-emblem"
                     onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                <div class="logo-emblem-fallback" style="display:none;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round">
                        <path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"/>
                        <line x1="4" y1="22" x2="4" y2="15"/>
                    </svg>
                </div>
                <div>
                    <div class="logo-name">ACTIVA</div>
                    <div class="logo-sub">DigitalLife Analyzer</div>
                </div>
            </div>

            {{-- Heading --}}
            <div class="brand-heading">
                <h2>Mari mulai<br>perjalananmu</h2>
                <p>Beberapa langkah lagi untuk<br>memahami pola digitalmu.</p>
            </div>

            {{-- Maskot — pojok kanan, sama seperti login --}}
            <div class="mascot-wrap">
                <img src="{{ asset('images/Maskot.png') }}"
                     alt="Maskot ACTIVA"
                     onerror="this.style.display='none'">
            </div>

            {{-- Tags --}}
            <div class="tags">
                <span class="tag"><i class="fas fa-lock"></i> Google Verified</span>
                <span class="tag"><i class="fas fa-robot"></i> Machine Learning</span>
                <span class="tag"><i class="fas fa-chart-line"></i> Analytics</span>
            </div>

        </div>
    </div>

    {{-- ══════════════════════════════════════════
         KANAN — Form putih, kurva melengkung
    ══════════════════════════════════════════ --}}
    <div class="auth-right-wrap">

        <svg class="curve-svg" viewBox="0 0 100 1000" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M100,0 C40,250 40,750 100,1000 L100,1000 L100,0 Z" fill="#ffffff"/>
        </svg>

        <div class="auth-right">
            <div class="auth-form-container">

                <div class="form-heading">
                    <h1>Buat Akun</h1>
                    <p>Verifikasi Google wajib untuk keamanan akun kamu</p>
                </div>

                {{-- Errors --}}
                @if($errors->has('google'))
                    <div class="alert alert-error">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        <span>{{ $errors->first('google') }}</span>
                    </div>
                @elseif($errors->any())
                    <div class="alert alert-error">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        <div>@foreach($errors->all() as $e)<div style="line-height:1.6">{{ $e }}</div>@endforeach</div>
                    </div>
                @endif

                {{-- ══ STEP 1: Google Verification ══ --}}
                <div class="gv-box" id="gv-wrap">
                    <div class="gv-step-label">
                        <div class="gv-step-num">1</div>
                        <span class="gv-step-text">Verifikasi Google</span>
                    </div>

                    <div id="gv-before">
                        <p style="color:var(--text-sec);font-size:.8125rem;margin-bottom:14px;line-height:1.6;">
                            Gunakan akun Gmail asli. Email kamu akan otomatis terisi setelah verifikasi.
                        </p>

                        <div class="gv-err" id="gv-err"></div>

                        {{-- Tombol Google CUSTOM (cantik) menggunakan Laravel Socialite --}}
                        <a href="{{ route('user.register.google-redirect') }}" id="gv-btn-custom" style="text-decoration: none;">
                            <div class="google-icon-wrap">
                                {{-- Google "G" SVG logo --}}
                                <svg width="18" height="18" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
                                    <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                                    <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                                    <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                                    <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
                                    <path fill="none" d="M0 0h48v48H0z"/>
                                </svg>
                            </div>
                            <span class="google-btn-text">Daftar dengan Google</span>
                        </a>
                    </div>

                    <div id="gv-after" style="display:none;">
                        <div class="gv-verified-row">
                            <img id="gv-avatar" class="gv-avatar" src="" alt="">
                            <div class="gv-verified-info">
                                <div class="gv-verified-badge">✓ Akun Google Terverifikasi</div>
                                <div class="gv-verified-email" id="gv-email"></div>
                            </div>
                            <button type="button" class="btn-gv-reset" onclick="resetGV()">Ganti</button>
                        </div>
                    </div>
                </div>

                {{-- ══ STEP 2: Register Form ══ --}}
                <div class="form-step-wrap" id="form-wrap">

                    <div class="form-step-label">
                        <div class="form-step-num" id="s2n">2</div>
                        <span class="form-step-title" id="s2l">Data Akun &amp; Diri</span>
                    </div>

                    <form method="POST" action="{{ url('/user/register') }}" id="form-reg" class="form-body">
                        @csrf

                        <div class="form-section">Informasi Akun</div>

                        {{-- Nama --}}
                        <div class="form-group">
                            <label class="form-label">Nama Lengkap</label>
                            <div class="input-wrap">
                                <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>
                                </svg>
                                <input name="name" class="form-input" placeholder="Masukkan nama lengkap"
                                       value="{{ old('name', session('reg_google_name','')) }}" required minlength="3">
                            </div>
                        </div>

                        {{-- Password --}}
                        <div class="form-grid-2">
                            <div class="form-group">
                                <label class="form-label">Password</label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                                        <rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                                    </svg>
                                    <input name="password" id="pw" type="password" class="form-input has-toggle" placeholder="Min. 8 karakter" required>
                                    <button type="button" class="input-toggle" onclick="tp('pw','eye1')">
                                        <svg id="eye1" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                                        </svg>
                                    </button>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Konfirmasi</label>
                                <div class="input-wrap">
                                    <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                                        <rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                                    </svg>
                                    <input name="password_confirmation" id="pw2" type="password" class="form-input has-toggle" placeholder="Ulangi password" required>
                                    <button type="button" class="input-toggle" onclick="tp('pw2','eye2')">
                                        <svg id="eye2" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                                        </svg>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div class="pw-strength" id="pws">
                            <div class="pwb" id="b1"></div><div class="pwb" id="b2"></div>
                            <div class="pwb" id="b3"></div><div class="pwb" id="b4"></div>
                            <span class="pw-strength-label" id="pwl"></span>
                        </div>

                        <div class="form-section" style="margin-top:4px;">Data Diri</div>

                        {{-- Jenis Kelamin + Tanggal Lahir --}}
                        <div class="form-grid-2">
                            <div class="form-group">
                                <label class="form-label">Jenis Kelamin</label>
                                <input type="hidden" name="gender" id="val-gender" value="{{ old('gender') }}" required>
                                <div class="cdd" id="dd-gender" onclick="toggleDD('gender')">
                                    <span class="cdd-lbl {{ old('gender') ? 'picked' : '' }}" id="lbl-gender">{{ old('gender') ? (old('gender')=='Male'?'Laki-laki':'Perempuan') : 'Pilih jenis kelamin' }}</span>
                                    <svg class="cdd-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
                                </div>
                                <div class="cdd-menu" id="menu-gender">
                                    <div class="cdd-item" onclick="pickDD('gender','Male','Laki-laki')">Laki-laki</div>
                                    <div class="cdd-item" onclick="pickDD('gender','Female','Perempuan')">Perempuan</div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Tanggal Lahir</label>
                                <input name="tgl_lahir" type="date" class="form-input no-icon"
                                       value="{{ old('tgl_lahir') }}" required
                                       max="{{ date('Y-m-d', strtotime('-10 years')) }}">
                            </div>
                        </div>

                        {{-- Wilayah --}}
                        <div class="form-group">
                            <label class="form-label">Wilayah / Tempat Tinggal</label>
                            <input type="hidden" name="region" id="val-region" value="{{ old('region') }}" required>
                            <div class="cdd" id="dd-region" onclick="toggleDD('region')">
                                <span class="cdd-lbl {{ old('region') ? 'picked' : '' }}" id="lbl-region">{{ old('region') ?: 'Pilih wilayah' }}</span>
                                <svg class="cdd-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
                            </div>
                            <div class="cdd-menu" id="menu-region">
                                <div class="cdd-item" onclick="pickDD('region','Africa','Afrika')">Afrika</div>
                                <div class="cdd-item" onclick="pickDD('region','Asia','Asia')">Asia</div>
                                <div class="cdd-item" onclick="pickDD('region','Europe','Eropa')">Eropa</div>
                                <div class="cdd-item" onclick="pickDD('region','Middle East','Timur Tengah')">Timur Tengah</div>
                                <div class="cdd-item" onclick="pickDD('region','North America','Amerika Utara')">Amerika Utara</div>
                                <div class="cdd-item" onclick="pickDD('region','South America','Amerika Selatan')">Amerika Selatan</div>
                            </div>
                        </div>

                        {{-- Pendidikan --}}
                        <div class="form-group">
                            <label class="form-label">Pendidikan Terakhir</label>
                            <input type="hidden" name="education_level" id="val-education_level" value="{{ old('education_level') }}" required>
                            <div class="cdd" id="dd-education_level" onclick="toggleDD('education_level')">
                                <span class="cdd-lbl {{ old('education_level') ? 'picked' : '' }}" id="lbl-education_level">{{ old('education_level') ?: 'Pilih pendidikan' }}</span>
                                <svg class="cdd-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
                            </div>
                            <div class="cdd-menu" id="menu-education_level">
                                <div class="cdd-item" onclick="pickDD('education_level','High School','SMA/SMK/Sederajat')">SMA/SMK/Sederajat</div>
                                <div class="cdd-item" onclick="pickDD('education_level','Bachelor','Sarjana')">Sarjana</div>
                                <div class="cdd-item" onclick="pickDD('education_level','Master','Magister')">Magister</div>
                                <div class="cdd-item" onclick="pickDD('education_level','PhD','Doktor')">Doktor</div>
                            </div>
                        </div>

                        {{-- Peran + Pendapatan --}}
                        <div class="form-grid-2">
                            <div class="form-group">
                                <label class="form-label">Peran Harian</label>
                                <input type="hidden" name="daily_role" id="val-daily_role" value="{{ old('daily_role') }}" required>
                                <div class="cdd" id="dd-daily_role" onclick="toggleDD('daily_role')">
                                    <span class="cdd-lbl {{ old('daily_role') ? 'picked' : '' }}" id="lbl-daily_role">{{ old('daily_role') ?: 'Pilih peran' }}</span>
                                    <svg class="cdd-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
                                </div>
                                <div class="cdd-menu" id="menu-daily_role">
                                    <div class="cdd-item" onclick="pickDD('daily_role','Student','Pelajar/Mahasiswa')">Pelajar/Mahasiswa</div>
                                    <div class="cdd-item" onclick="pickDD('daily_role','Full-time','Karyawan Penuh Waktu')">Karyawan Penuh Waktu</div>
                                    <div class="cdd-item" onclick="pickDD('daily_role','Part-time','Karyawan Paruh Waktu')">Karyawan Paruh Waktu</div>
                                    <div class="cdd-item" onclick="pickDD('daily_role','Caregiver','Pengurus Rumah Tangga')">Pengurus Rumah Tangga</div>
                                    <div class="cdd-item" onclick="pickDD('daily_role','Unemployed','Tidak Bekerja')">Tidak Bekerja</div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Tingkat Pendapatan</label>
                                <input type="hidden" name="income_level" id="val-income_level" value="{{ old('income_level') }}" required>
                                <div class="cdd" id="dd-income_level" onclick="toggleDD('income_level')">
                                    <span class="cdd-lbl {{ old('income_level') ? 'picked' : '' }}" id="lbl-income_level">{{ old('income_level') ?: 'Pilih pendapatan' }}</span>
                                    <svg class="cdd-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
                                </div>
                                <div class="cdd-menu" id="menu-income_level">
                                    <div class="cdd-item" onclick="pickDD('income_level','Low','Rendah')">Rendah</div>
                                    <div class="cdd-item" onclick="pickDD('income_level','Lower-Mid','Menengah Bawah')">Menengah Bawah</div>
                                    <div class="cdd-item" onclick="pickDD('income_level','Upper-Mid','Menengah Atas')">Menengah Atas</div>
                                    <div class="cdd-item" onclick="pickDD('income_level','High','Tinggi')">Tinggi</div>
                                </div>
                            </div>
                        </div>

                        <button type="submit" class="btn-primary" id="btn-reg">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                                <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                                <circle cx="8.5" cy="7" r="4"/>
                                <line x1="20" y1="8" x2="20" y2="14"/>
                                <line x1="23" y1="11" x2="17" y2="11"/>
                            </svg>
                            Daftar Sekarang
                        </button>
                    </form>
                </div>

                <div class="form-footer">
                    <p>Sudah punya akun? <a href="{{ url('/user/login') }}">Masuk</a></p>
                </div>

            </div>
        </div>
    </div>

    <script>
    const CSRF      = document.querySelector('meta[name="csrf-token"]').content;
    let   gOK       = {{ session('reg_google_verified') ? 'true' : 'false' }};

    document.addEventListener('DOMContentLoaded', () => {
        @if(session('reg_google_verified') && session('reg_google_email'))
            showVerified('{{ session("reg_google_email") }}', '{{ session("reg_google_name","") }}', '{{ session("reg_google_picture","") }}');
        @endif
    });

    function showVerified(email, name, pic) {
        document.getElementById('gv-before').style.display = 'none';
        document.getElementById('gv-after').style.display  = 'block';
        document.getElementById('gv-email').textContent = email;
        if (pic) { const img=document.getElementById('gv-avatar'); img.src=pic; img.style.display='block'; }
        const ni = document.querySelector('input[name="name"]');
        if (ni && !ni.value && name) ni.value = name;
        document.getElementById('form-wrap').classList.add('active');
        document.getElementById('s2n').classList.add('active');
        document.getElementById('s2l').classList.add('active');
        gOK = true;
    }

    function resetGV() {
        document.getElementById('gv-before').style.display = 'block';
        document.getElementById('gv-after').style.display  = 'none';
        document.getElementById('form-wrap').classList.remove('active');
        document.getElementById('s2n').classList.remove('active');
        document.getElementById('s2l').classList.remove('active');
        gOK = false;
        setTimeout(initGoogle, 100);
    }

    function showErr(m) {
        const el = document.getElementById('gv-err');
        el.textContent = '⚠ ' + m;
        el.style.display = 'block';
    }

    function tp(id, iconId) {
        const i = document.getElementById(id);
        i.type = i.type === 'password' ? 'text' : 'password';
    }

    document.getElementById('pw').addEventListener('input', function() {
        const v = this.value;
        const w = document.getElementById('pws');
        if (!v) { w.classList.remove('show'); return; }
        w.classList.add('show');
        let s = 0;
        if (v.length >= 8) s++;
        if (/[A-Z]/.test(v)) s++;
        if (/[0-9]/.test(v)) s++;
        if (/[^a-zA-Z0-9]/.test(v)) s++;
        const c = ['','#ef4444','#f59e0b','#22c55e','#1abc8c'];
        const l = ['','Lemah','Sedang','Kuat','Sangat Kuat'];
        ['b1','b2','b3','b4'].forEach((id, i) => {
            document.getElementById(id).style.background = i < s ? c[s] : 'var(--border-input)';
        });
        const p = document.getElementById('pwl');
        p.textContent = l[s]; p.style.color = c[s];
    });

    function toggleDD(name) {
        const menu = document.getElementById('menu-' + name);
        const btn  = document.getElementById('dd-' + name);
        const isOpen = menu.classList.contains('open');
        closeAllDD();
        if (!isOpen) { menu.classList.add('open'); btn.classList.add('open'); }
    }
    function pickDD(name, value, label) {
        document.getElementById('val-' + name).value = value;
        const lbl = document.getElementById('lbl-' + name);
        lbl.textContent = label; lbl.classList.add('picked');
        document.querySelectorAll('#menu-' + name + ' .cdd-item').forEach(el => {
            el.classList.toggle('selected', el.textContent.trim() === label);
        });
        closeAllDD();
    }
    function closeAllDD() {
        document.querySelectorAll('.cdd-menu').forEach(m => m.classList.remove('open'));
        document.querySelectorAll('.cdd').forEach(b => b.classList.remove('open'));
    }
    document.addEventListener('click', e => {
        if (!e.target.closest('.form-group') && !e.target.closest('.cdd')) closeAllDD();
    });

    document.getElementById('form-reg').addEventListener('submit', function(e) {
        if (!gOK) {
            e.preventDefault();
            showErr('Verifikasi Google wajib dilakukan sebelum mendaftar.');
            document.getElementById('gv-wrap').scrollIntoView({behavior:'smooth'});
            return;
        }
        const required = ['gender','region','education_level','daily_role','income_level'];
        for (const f of required) {
            if (!document.getElementById('val-' + f).value) {
                e.preventDefault();
                const dd = document.getElementById('dd-' + f);
                dd.style.borderColor = '#ef4444';
                dd.scrollIntoView({behavior:'smooth', block:'center'});
                setTimeout(() => dd.style.borderColor = '', 2000);
                return;
            }
        }
        const b = document.getElementById('btn-reg');
        b.disabled = true;
        b.innerHTML = '<div class="btn-spinner"></div> Mendaftarkan...';
    });
    </script>

</body>
</html>