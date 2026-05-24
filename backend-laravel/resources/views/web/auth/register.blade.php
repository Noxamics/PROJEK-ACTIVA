<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daftar — ACTIVA</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <link href="{{ asset('css/web.css') }}" rel="stylesheet">
</head>
<body>
<div class="auth-page" style="align-items:stretch;min-height:100vh;">
    <div class="auth-left" style="overflow-y:auto;min-height:100vh;padding:40px 0;">
        <div class="auth-form-container anim-fade" style="max-width:520px;">

            {{-- Brand --}}
            <div style="margin-bottom:32px;">
                <div style="display:flex;align-items:center;gap:12px;margin-bottom:24px;">
                    <div class="sidebar-logo"><svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round"><path d="M9 11l3 3L22 4"/></svg></div>
                    <div>
                        <div style="color:var(--text-primary);font-size:1.25rem;font-weight:800;">ACTIVA</div>
                        <div style="color:var(--text-secondary);font-size:.6875rem;font-weight:600;letter-spacing:.05em;text-transform:uppercase;">DigitalLife Analyzer</div>
                    </div>
                </div>
                <h1 style="color:var(--text-primary);margin-bottom:8px;">Buat Akun</h1>
                <p style="color:var(--text-secondary);font-size:.9375rem;">Verifikasi Google wajib untuk keamanan akun kamu</p>
            </div>

            {{-- Errors --}}
            @if($errors->has('google'))
                <div style="padding:12px 16px;background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.2);border-radius:var(--radius-md);margin-bottom:20px;">
                    <p style="color:var(--red);font-size:.875rem;font-weight:600;">{{ $errors->first('google') }}</p>
                </div>
            @elseif($errors->any())
                <div style="padding:12px 16px;background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.2);border-radius:var(--radius-md);margin-bottom:20px;">
                    @foreach($errors->all() as $e)
                        <p style="color:var(--red);font-size:.875rem;font-weight:600;line-height:1.6;">{{ $e }}</p>
                    @endforeach
                </div>
            @endif

            {{-- ═══ STEP 1: Google Verification ═══ --}}
            <div style="background:rgba(13,148,136,.06);border:1.5px solid rgba(13,148,136,.2);border-radius:var(--radius-lg);padding:20px;margin-bottom:20px;" id="gv-wrap">
                <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px;">
                    <div style="width:22px;height:22px;background:rgba(13,148,136,.2);border-radius:6px;display:flex;align-items:center;justify-content:center;font-size:.625rem;font-weight:800;color:var(--teal);">1</div>
                    <span style="font-size:.6875rem;font-weight:800;color:var(--teal);letter-spacing:.1em;text-transform:uppercase;">Verifikasi Google</span>
                </div>

                {{-- Unverified --}}
                <div id="gv-before">
                    <p style="color:var(--text-secondary);font-size:.8125rem;margin-bottom:14px;line-height:1.6;">Gunakan akun Gmail asli. Email kamu akan otomatis terisi setelah verifikasi.</p>
                    <div id="gv-err" style="display:none;padding:10px 14px;background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.2);border-radius:var(--radius-md);color:var(--red);font-size:.8125rem;font-weight:600;margin-bottom:12px;"></div>

                    <div id="gv-loading" style="display:flex;align-items:center;justify-content:center;gap:10px;padding:13px;background:rgba(255,255,255,.04);border:1.5px solid var(--border-card);border-radius:var(--radius-md);">
                        <div style="width:16px;height:16px;border:2px solid var(--border-card);border-top-color:var(--teal);border-radius:50%;animation:spin .9s linear infinite;"></div>
                        <span style="color:var(--text-secondary);font-size:.875rem;">Memuat tombol Google...</span>
                    </div>
                    <div id="gv-btn" style="display:none;justify-content:center;"></div>
                </div>

                {{-- Verified --}}
                <div id="gv-after" style="display:none;">
                    <div style="display:flex;align-items:center;gap:14px;padding:14px 16px;background:rgba(13,148,136,.08);border:1.5px solid rgba(13,148,136,.25);border-radius:var(--radius-md);">
                        <img id="gv-avatar" src="" alt="" style="width:44px;height:44px;border-radius:50%;border:2px solid rgba(13,148,136,.4);display:none;">
                        <div style="flex:1;min-width:0;">
                            <div style="font-size:.75rem;font-weight:700;color:var(--teal);margin-bottom:3px;">✓ Akun Google Terverifikasi</div>
                            <div id="gv-email" style="font-size:.9375rem;color:var(--text-primary);font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"></div>
                        </div>
                        <button type="button" onclick="resetGV()" style="background:rgba(255,255,255,.06);border:1px solid var(--border-card);color:var(--text-secondary);font-size:.75rem;cursor:pointer;padding:6px 12px;border-radius:8px;font-family:inherit;font-weight:600;flex-shrink:0;">Ganti</button>
                    </div>
                </div>
            </div>

            {{-- ═══ STEP 2: Register Form ═══ --}}
            <div id="form-wrap" style="opacity:.35;pointer-events:none;transition:opacity .35s;">
                <div style="display:flex;align-items:center;gap:10px;margin-bottom:20px;">
                    <div id="s2n" style="width:22px;height:22px;background:rgba(100,116,139,.15);border-radius:6px;display:flex;align-items:center;justify-content:center;font-size:.625rem;font-weight:800;color:var(--text-secondary);">2</div>
                    <span id="s2l" style="font-size:.6875rem;font-weight:800;color:var(--text-secondary);letter-spacing:.1em;text-transform:uppercase;">Data Akun & Diri</span>
                </div>

                <form method="POST" action="{{ url('/user/register') }}" id="form-reg" style="display:flex;flex-direction:column;gap:16px;">
                    @csrf

                    <div style="font-size:.6875rem;font-weight:700;color:var(--teal);letter-spacing:.08em;text-transform:uppercase;padding-bottom:10px;border-bottom:1px solid var(--border-card);">INFORMASI AKUN</div>

                    <div class="form-group">
                        <label class="form-label form-label-dark">Nama Lengkap</label>
                        <input name="name" class="form-input form-input-dark" placeholder="Masukkan nama lengkap" value="{{ old('name', session('reg_google_name','')) }}" required minlength="3">
                    </div>

                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                        <div class="form-group">
                            <label class="form-label form-label-dark">Password</label>
                            <div style="position:relative;">
                                <input name="password" id="pw" type="password" class="form-input form-input-dark" placeholder="Min. 8 karakter" required style="padding-right:44px;">
                                <button type="button" onclick="tp('pw')" style="position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;color:var(--text-secondary);padding:0;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label form-label-dark">Konfirmasi</label>
                            <div style="position:relative;">
                                <input name="password_confirmation" id="pw2" type="password" class="form-input form-input-dark" placeholder="Ulangi password" required style="padding-right:44px;">
                                <button type="button" onclick="tp('pw2')" style="position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;color:var(--text-secondary);padding:0;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
                            </div>
                        </div>
                    </div>

                    <div id="pws" style="display:none;align-items:center;gap:5px;">
                        <div class="pwb" id="b1"></div><div class="pwb" id="b2"></div>
                        <div class="pwb" id="b3"></div><div class="pwb" id="b4"></div>
                        <span id="pwl" style="font-size:.6875rem;font-weight:700;margin-left:6px;"></span>
                    </div>

                    <div style="font-size:.6875rem;font-weight:700;color:var(--teal);letter-spacing:.08em;text-transform:uppercase;padding-bottom:10px;border-bottom:1px solid var(--border-card);margin-top:4px;">DATA DIRI</div>

                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                        {{-- Jenis Kelamin --}}
                        <div class="form-group">
                            <label class="form-label form-label-dark">Jenis Kelamin</label>
                            <input type="hidden" name="gender" id="val-gender" value="{{ old('gender') }}" required>
                            <div class="cdd" id="dd-gender" onclick="toggleDD('gender')">
                                <span class="cdd-lbl" id="lbl-gender">{{ old('gender') ? (old('gender')=='Male'?'Laki-laki':'Perempuan') : 'Pilih jenis kelamin' }}</span>
                                <svg class="cdd-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
                            </div>
                            <div class="cdd-menu" id="menu-gender">
                                <div class="cdd-item" onclick="pickDD('gender','Male','Laki-laki')">Laki-laki</div>
                                <div class="cdd-item" onclick="pickDD('gender','Female','Perempuan')">Perempuan</div>
                            </div>
                        </div>
                        {{-- Tanggal Lahir --}}
                        <div class="form-group">
                            <label class="form-label form-label-dark">Tanggal Lahir</label>
                            <input name="tgl_lahir" type="date" class="form-input form-input-dark" value="{{ old('tgl_lahir') }}" required max="{{ date('Y-m-d', strtotime('-10 years')) }}">
                        </div>
                    </div>

                    {{-- Wilayah --}}
                    <div class="form-group">
                        <label class="form-label form-label-dark">Wilayah / Tempat Tinggal</label>
                        <input type="hidden" name="region" id="val-region" value="{{ old('region') }}" required>
                        <div class="cdd" id="dd-region" onclick="toggleDD('region')">
                            <span class="cdd-lbl" id="lbl-region">{{ old('region') ? old('region') : 'Pilih wilayah' }}</span>
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
                        <label class="form-label form-label-dark">Pendidikan Terakhir</label>
                        <input type="hidden" name="education_level" id="val-education_level" value="{{ old('education_level') }}" required>
                        <div class="cdd" id="dd-education_level" onclick="toggleDD('education_level')">
                            <span class="cdd-lbl" id="lbl-education_level">{{ old('education_level') ? old('education_level') : 'Pilih pendidikan' }}</span>
                            <svg class="cdd-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
                        </div>
                        <div class="cdd-menu" id="menu-education_level">
                            <div class="cdd-item" onclick="pickDD('education_level','High School','SMA/SMK/Sederajat')">SMA/SMK/Sederajat</div>
                            <div class="cdd-item" onclick="pickDD('education_level','Bachelor','Sarjana')">Sarjana</div>
                            <div class="cdd-item" onclick="pickDD('education_level','Master','Magister')">Magister</div>
                            <div class="cdd-item" onclick="pickDD('education_level','PhD','Doktor')">Doktor</div>
                        </div>
                    </div>

                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                        {{-- Peran Harian --}}
                        <div class="form-group" style="position:relative;">
                            <label class="form-label form-label-dark">Peran Harian</label>
                            <input type="hidden" name="daily_role" id="val-daily_role" value="{{ old('daily_role') }}" required>
                            <div class="cdd" id="dd-daily_role" onclick="toggleDD('daily_role')">
                                <span class="cdd-lbl" id="lbl-daily_role">{{ old('daily_role') ? old('daily_role') : 'Pilih peran' }}</span>
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
                        {{-- Pendapatan --}}
                        <div class="form-group" style="position:relative;">
                            <label class="form-label form-label-dark">Tingkat Pendapatan</label>
                            <input type="hidden" name="income_level" id="val-income_level" value="{{ old('income_level') }}" required>
                            <div class="cdd" id="dd-income_level" onclick="toggleDD('income_level')">
                                <span class="cdd-lbl" id="lbl-income_level">{{ old('income_level') ? old('income_level') : 'Pilih pendapatan' }}</span>
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

                    <button type="submit" class="btn btn-primary btn-lg btn-block" id="btn-reg" style="margin-top:8px;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
                        Daftar Sekarang
                    </button>
                </form>
            </div>

            <p style="color:var(--text-secondary);text-align:center;margin-top:28px;font-size:.875rem;">
                Sudah punya akun? <a href="{{ url('/user/login') }}" style="color:var(--teal);font-weight:700;">Masuk</a>
            </p>
        </div>
    </div>

    {{-- RIGHT --}}
    <div class="auth-right" style="position:sticky;top:0;height:100vh;align-self:flex-start;">
        <div class="auth-brand">
            <div style="width:80px;height:80px;margin:0 auto 28px;background:rgba(255,255,255,.1);border-radius:24px;display:flex;align-items:center;justify-content:center;">
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
            </div>
            <h2>Mulai Perjalananmu</h2>
            <p style="margin-top:12px;">Daftarkan dirimu dan mulai analisis kebiasaan digital secara personal dengan teknologi AI.</p>
            <div style="display:flex;gap:12px;justify-content:center;margin-top:32px;flex-wrap:wrap;">
                <div class="tag">🔒 Google Verified</div>
                <div class="tag">🤖 Machine Learning</div>
                <div class="tag">📊 Analytics</div>
            </div>
        </div>
    </div>
</div>

<style>
@keyframes spin { to { transform: rotate(360deg); } }
.pwb { flex:1; height:4px; border-radius:4px; background:var(--border-card); transition:background .3s; }
#pws { display:flex; align-items:center; }

/* Custom Dropdown */
.cdd {
    display:flex; align-items:center; justify-content:space-between;
    width:100%; padding:10px 14px;
    background:var(--bg-input,rgba(15,30,50,.7));
    border:1.5px solid var(--border-card);
    border-radius:var(--radius-md,10px);
    cursor:pointer; font-size:.9375rem; font-family:inherit;
    color:var(--text-secondary); transition:border-color .2s, box-shadow .2s;
    user-select:none; position:relative; z-index:1;
}
.cdd:hover { border-color:var(--teal); }
.cdd.open  { border-color:var(--teal); box-shadow:0 0 0 3px rgba(13,148,136,.15); color:var(--text-primary); }
.cdd-lbl   { white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.cdd-lbl.picked { color:var(--text-primary); }
.cdd-arrow { flex-shrink:0; color:var(--text-secondary); transition:transform .25s cubic-bezier(.4,0,.2,1); }
.cdd.open .cdd-arrow { transform:rotate(180deg); color:var(--teal); }
.form-group { position:relative; }
.cdd-menu {
    position:absolute; left:0; right:0;
    background:var(--bg-card,#1a2d42);
    border:1.5px solid var(--border-card);
    border-radius:var(--radius-md,10px);
    margin-top:6px; z-index:999;
    box-shadow:0 12px 32px rgba(0,0,0,.35);
    overflow:hidden;
    max-height:0; opacity:0;
    transition:max-height .28s cubic-bezier(.4,0,.2,1), opacity .2s ease;
    pointer-events:none;
}
.cdd-menu.open {
    max-height:280px; opacity:1;
    pointer-events:auto;
    overflow-y:auto;
}
.cdd-item {
    padding:11px 16px; font-size:.9rem; color:var(--text-secondary);
    cursor:pointer; transition:background .15s, color .15s;
    border-bottom:1px solid rgba(255,255,255,.04);
}
.cdd-item:last-child { border-bottom:none; }
.cdd-item:hover { background:rgba(13,148,136,.12); color:var(--teal); }
.cdd-item.selected { background:rgba(13,148,136,.1); color:var(--teal); font-weight:600; }
</style>

<script src="https://accounts.google.com/gsi/client" async></script>
<script>
const CLIENT_ID = '{{ env("GOOGLE_CLIENT_ID") }}';
const CSRF      = document.querySelector('meta[name="csrf-token"]').content;
let   gOK       = json(session('reg_google_verified', false));

if(session('reg_google_verified') && session('reg_google_email'))
document.addEventListener('DOMContentLoaded', () => {
    showVerified('{{ session("reg_google_email") }}', '{{ session("reg_google_name","") }}', null);
});


function initGoogle() {
    if (!CLIENT_ID || typeof google === 'undefined') { showFail(); return; }
    try {
        google.accounts.id.initialize({
            client_id: CLIENT_ID,
            callback : onGCB,
            auto_select: false,
            use_fedcm_for_prompt: true,
        });
        google.accounts.id.renderButton(
            document.getElementById('gv-btn'),
            { theme:'outline', size:'large', text:'signin_with', shape:'rectangular', width:440 }
        );
        setTimeout(() => {
            const c = document.getElementById('gv-btn');
            if (!c.children.length) { showFail(); return; }
            document.getElementById('gv-loading').style.display = 'none';
            c.style.display = 'flex';
        }, 2500);
    } catch(e) { showFail(); }
}

function showFail() {
    // Google button failed to load — retry silently
    document.getElementById('gv-loading').style.display = 'none';
}

window.addEventListener('load', () => {
    const t = setTimeout(showFail, 4000);
    if (typeof google !== 'undefined') { clearTimeout(t); initGoogle(); }
    else {
        const s = document.querySelector('script[src*="accounts.google"]');
        if (s) s.addEventListener('load', () => { clearTimeout(t); initGoogle(); });
        else showFail();
    }
});

function onGCB(res) {
    if (!res.credential) { showErr('Verifikasi dibatalkan.'); return; }
    const c = document.getElementById('gv-btn');
    c.style.opacity = '.4'; c.style.pointerEvents = 'none';
    document.getElementById('gv-err').style.display = 'none';
    fetch('{{ url("/user/register/google-verify") }}', {
        method: 'POST',
        headers: {'Content-Type':'application/json','X-CSRF-TOKEN': CSRF},
        body: JSON.stringify({id_token: res.credential}),
    })
    .then(r => r.json())
    .then(d => {
        c.style.opacity = '1'; c.style.pointerEvents = 'auto';
        if (d.success) { showVerified(d.email, d.name, d.picture); }
        else {
            showErr(d.message || 'Gagal memverifikasi.');
            if (d.already_exists) setTimeout(() => location = '{{ url("/user/login") }}', 2000);
        }
    })
    .catch(() => { c.style.opacity='1'; c.style.pointerEvents='auto'; showErr('Koneksi gagal. Coba lagi.'); });
}

function showVerified(email, name, pic) {
    document.getElementById('gv-before').style.display = 'none';
    document.getElementById('gv-after').style.display  = 'block';
    document.getElementById('gv-email').textContent = email;
    if (pic) { const img=document.getElementById('gv-avatar'); img.src=pic; img.style.display='block'; }
    const ni = document.querySelector('input[name="name"]');
    if (ni && !ni.value && name) ni.value = name;
    const fw = document.getElementById('form-wrap');
    fw.style.opacity = '1'; fw.style.pointerEvents = 'auto';
    const n=document.getElementById('s2n'), l=document.getElementById('s2l');
    n.style.cssText += ';background:rgba(13,148,136,.2);color:var(--teal);border:1px solid rgba(13,148,136,.3);';
    l.style.color = 'var(--teal)';
    gOK = true;
}

function resetGV() {
    document.getElementById('gv-before').style.display = 'block';
    document.getElementById('gv-after').style.display  = 'none';
    document.getElementById('form-wrap').style.opacity = '.35';
    document.getElementById('form-wrap').style.pointerEvents = 'none';
    const n=document.getElementById('s2n'), l=document.getElementById('s2l');
    n.style.cssText = 'width:22px;height:22px;background:rgba(100,116,139,.15);border-radius:6px;display:flex;align-items:center;justify-content:center;font-size:.625rem;font-weight:800;color:var(--text-secondary);';
    l.style.color = 'var(--text-secondary)';
    gOK = false;
    setTimeout(initGoogle, 100);
}

function showErr(m) {
    const el=document.getElementById('gv-err');
    el.textContent='⚠ '+m; el.style.display='block';
}

function tp(id) { const i=document.getElementById(id); i.type=i.type==='password'?'text':'password'; }

document.getElementById('pw').addEventListener('input', function() {
    const v=this.value, w=document.getElementById('pws');
    if(!v){w.style.display='none';return;} w.style.display='flex';
    let s=0;
    if(v.length>=8)s++; if(/[A-Z]/.test(v))s++; if(/[0-9]/.test(v))s++; if(/[^a-zA-Z0-9]/.test(v))s++;
    const c=['','#ef4444','#f59e0b','#22c55e','#0d9488'],l=['','Lemah','Sedang','Kuat','Sangat Kuat'];
    ['b1','b2','b3','b4'].forEach((id,i)=>document.getElementById(id).style.background=i<s?c[s]:'var(--border-card)');
    const p=document.getElementById('pwl'); p.textContent=l[s]; p.style.color=c[s];
});

// ── Custom Dropdown ───────────────────────────────────────────
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
    lbl.textContent = label;
    lbl.classList.add('picked');
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
    // Validate custom dropdowns
    const required = ['gender','region','education_level','daily_role','income_level'];
    for (const f of required) {
        if (!document.getElementById('val-' + f).value) {
            e.preventDefault();
            const dd = document.getElementById('dd-' + f);
            dd.style.borderColor = 'var(--red)';
            dd.scrollIntoView({behavior:'smooth', block:'center'});
            setTimeout(() => dd.style.borderColor = '', 2000);
            return;
        }
    }
    const b=document.getElementById('btn-reg');
    b.disabled=true;
    b.innerHTML='<div class="spinner" style="width:18px;height:18px;border-width:2px;"></div> Mendaftarkan...';
});
</script>
</body>
</html>
