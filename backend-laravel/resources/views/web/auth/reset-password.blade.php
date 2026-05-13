<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Buat Password Baru — ACTIVA</title>
    <link href="{{ asset('css/web.css') }}" rel="stylesheet">
</head>
<body>
<div class="auth-page">
    <div class="auth-left">
        <div class="auth-form-container anim-fade">

            <a href="{{ url('/user/login') }}" class="fp-back-btn">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 5l-7 7 7 7"/></svg>
            </a>

            <div class="fp-icon-wrap fp-icon-green" style="margin-top:24px;">
                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 9.9-1"/></svg>
            </div>

            <div style="margin:20px 0 28px;">
                <h1 style="color:var(--text-primary);font-size:1.75rem;margin-bottom:8px;">Buat Password Baru</h1>
                <p style="color:var(--text-secondary);font-size:.9375rem;line-height:1.6;">
                    Password baru harus minimal 8 karakter<br>dan mengandung huruf serta angka.
                </p>
            </div>

            @if($errors->any())
                <div class="fp-alert fp-alert-error">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <span>{{ $errors->first() }}</span>
                </div>
            @endif

            @if(session('error'))
                <div class="fp-alert fp-alert-error">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <span>{{ session('error') }}</span>
                </div>
            @endif

            <form method="POST" action="{{ url('/user/reset-password') }}" id="form-reset" style="display:flex;flex-direction:column;gap:16px;">
                @csrf

                {{-- Password Baru --}}
                <div class="form-group">
                    <label class="form-label form-label-dark" for="rp-password">Password Baru</label>
                    <div class="fp-input-wrap">
                        <span class="fp-input-icon">
                            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        </span>
                        <input type="password" id="rp-password" name="password"
                            class="form-input form-input-dark fp-input"
                            placeholder="Min. 8 karakter" required
                            autocomplete="new-password">
                        <button type="button" class="fp-eye-btn" id="rp-eye-pass" onclick="togglePass('rp-password','rp-eye-pass')" tabindex="-1">
                            <svg id="rp-eye-pass-icon" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                </div>

                {{-- Konfirmasi Password --}}
                <div class="form-group">
                    <label class="form-label form-label-dark" for="rp-confirm">Konfirmasi Password</label>
                    <div class="fp-input-wrap">
                        <span class="fp-input-icon">
                            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        </span>
                        <input type="password" id="rp-confirm" name="password_confirmation"
                            class="form-input form-input-dark fp-input"
                            placeholder="Ulangi password baru" required
                            autocomplete="new-password">
                        <button type="button" class="fp-eye-btn" id="rp-eye-conf" onclick="togglePass('rp-confirm','rp-eye-conf')" tabindex="-1">
                            <svg id="rp-eye-conf-icon" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                    <p class="fp-mismatch" id="rp-mismatch" style="display:none;">
                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                        Password tidak cocok
                    </p>
                </div>

                {{-- Password Strength Card --}}
                <div class="fp-req-card" id="rp-req-card">
                    <p class="fp-req-title">Syarat password:</p>
                    <div class="fp-req-item" id="req-len">
                        <span class="fp-req-dot"></span>Minimal 8 karakter
                    </div>
                    <div class="fp-req-item" id="req-num">
                        <span class="fp-req-dot"></span>Mengandung angka
                    </div>
                    <div class="fp-req-item" id="req-letter">
                        <span class="fp-req-dot"></span>Mengandung huruf
                    </div>
                </div>

                <button type="submit" class="btn btn-primary btn-lg btn-block" id="btn-reset" disabled>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v14a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                    Simpan Password Baru
                </button>
            </form>

        </div>
    </div>

    <div class="auth-right">
        <div class="auth-brand">
            <div style="width:80px;height:80px;margin:0 auto 28px;background:rgba(34,197,94,.15);border:1px solid rgba(34,197,94,.3);border-radius:24px;display:flex;align-items:center;justify-content:center;">
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#22C55E" stroke-width="2" stroke-linecap="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            </div>
            <h2>Password Aman & Kuat</h2>
            <p style="margin-top:12px;">Buat password yang unik dan sulit ditebak untuk keamanan akun ACTIVA kamu.</p>
            <div style="display:flex;gap:12px;justify-content:center;margin-top:32px;flex-wrap:wrap;">
                <div class="tag">🛡 Terenkripsi</div>
                <div class="tag">🔑 Password Kuat</div>
                <div class="tag">✅ Aman</div>
            </div>
        </div>
    </div>
</div>

{{-- ── Success Modal ── --}}
@if(session('reset_success'))
<div class="modal-overlay" id="modal-success" style="display:flex;">
    <div class="modal-box" style="max-width:400px;text-align:center;padding:40px 32px;">
        <div style="width:72px;height:72px;margin:0 auto 20px;background:rgba(13,148,136,.12);border-radius:50%;display:flex;align-items:center;justify-content:center;">
            <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="var(--teal)" stroke-width="2.5" stroke-linecap="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <h3 style="color:var(--text-dark);margin-bottom:10px;">Password Berhasil Direset!</h3>
        <p style="color:var(--text-muted);font-size:.9375rem;line-height:1.6;margin-bottom:28px;">
            Password kamu berhasil diubah.<br>Silakan login dengan password baru.
        </p>
        <a href="{{ url('/user/login') }}" class="btn btn-primary btn-block">
            Login Sekarang
        </a>
    </div>
</div>
@endif

<style>
.fp-back-btn{display:inline-flex;align-items:center;justify-content:center;width:40px;height:40px;background:rgba(26,45,66,.8);border:1px solid var(--border-card);border-radius:var(--radius-md);color:var(--text-primary);transition:all .2s}
.fp-back-btn:hover{background:rgba(13,148,136,.15);border-color:rgba(13,148,136,.4);color:var(--teal)}
.fp-icon-wrap{width:64px;height:64px;border-radius:18px;display:flex;align-items:center;justify-content:center}
.fp-icon-green{background:rgba(34,197,94,.15);border:1px solid rgba(34,197,94,.3);color:var(--green)}
.fp-alert{display:flex;align-items:center;gap:10px;padding:12px 16px;border-radius:var(--radius-md);font-size:.875rem;font-weight:600;margin-bottom:20px}
.fp-alert-error{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.2);color:var(--red)}
.fp-input-wrap{position:relative}
.fp-input-icon{position:absolute;left:14px;top:50%;transform:translateY(-50%);color:var(--text-secondary);pointer-events:none;display:flex;align-items:center}
.fp-eye-btn{position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;color:var(--text-secondary);cursor:pointer;display:flex;align-items:center;padding:4px;transition:color .2s}
.fp-eye-btn:hover{color:var(--teal)}
.fp-input{padding-left:44px!important;padding-right:44px!important}
.fp-mismatch{display:flex;align-items:center;gap:5px;color:var(--red);font-size:.8125rem;margin-top:6px}
.fp-req-card{background:rgba(255,255,255,.04);border:1px solid var(--border-card);border-radius:var(--radius-md);padding:14px 16px}
.fp-req-title{font-size:.75rem;font-weight:700;color:var(--text-secondary);margin-bottom:10px;text-transform:uppercase;letter-spacing:.06em}
.fp-req-item{display:flex;align-items:center;gap:8px;font-size:.8125rem;color:var(--text-secondary);margin-bottom:6px;transition:color .2s}
.fp-req-item:last-child{margin-bottom:0}
.fp-req-item.met{color:#4ade80}
.fp-req-dot{width:14px;height:14px;border-radius:50%;border:2px solid currentColor;display:inline-flex;align-items:center;justify-content:center;flex-shrink:0;transition:all .2s}
.fp-req-item.met .fp-req-dot{background:#4ade80;border-color:#4ade80}
.fp-req-item.met .fp-req-dot::after{content:'';display:block;width:5px;height:5px;border-radius:50%;background:#fff}
</style>

<script>
function togglePass(inputId, btnId) {
    const inp = document.getElementById(inputId);
    const isHidden = inp.type === 'password';
    inp.type = isHidden ? 'text' : 'password';
    const icon = document.getElementById(btnId + '-icon');
    icon.innerHTML = isHidden
        ? '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/>'
        : '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>';
}

(function(){
    const passIn  = document.getElementById('rp-password');
    const confIn  = document.getElementById('rp-confirm');
    const btnReset= document.getElementById('btn-reset');
    const mismatch= document.getElementById('rp-mismatch');

    const reqLen   = document.getElementById('req-len');
    const reqNum   = document.getElementById('req-num');
    const reqLetter= document.getElementById('req-letter');

    function setReq(el, met) {
        el.classList.toggle('met', met);
    }

    function validate() {
        const pass = passIn.value;
        const conf = confIn.value;
        const lenOk    = pass.length >= 8;
        const numOk    = /[0-9]/.test(pass);
        const letterOk = /[a-zA-Z]/.test(pass);
        const matchOk  = pass === conf && conf.length > 0;

        setReq(reqLen,    lenOk);
        setReq(reqNum,    numOk);
        setReq(reqLetter, letterOk);

        if (conf.length > 0) {
            mismatch.style.display = matchOk ? 'none' : 'flex';
        } else {
            mismatch.style.display = 'none';
        }

        btnReset.disabled = !(lenOk && numOk && letterOk && matchOk);
    }

    passIn.addEventListener('input', validate);
    confIn.addEventListener('input', validate);

    document.getElementById('form-reset').addEventListener('submit', function(){
        btnReset.disabled = true;
        btnReset.innerHTML = '<div class="spinner" style="width:18px;height:18px;border-width:2px;"></div> Menyimpan...';
    });
})();
</script>
</body>
</html>
