<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lupa Password — ACTIVA</title>
    <meta name="description" content="Reset password akun ACTIVA kamu dengan kode OTP yang dikirim ke email.">
    <link href="{{ asset('css/web.css') }}" rel="stylesheet">
</head>
<body>
<div class="auth-page">
    <div class="auth-left">
        <div class="auth-form-container anim-fade">

            {{-- ── Back Button ── --}}
            <a href="{{ url('/user/login') }}" class="fp-back-btn" id="btn-back-login">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 5l-7 7 7 7"/></svg>
            </a>

            {{-- ── Icon & Heading ── --}}
            <div class="fp-icon-wrap fp-icon-teal" style="margin-top:24px;">
                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/><circle cx="12" cy="16" r="1"/></svg>
            </div>

            <div style="margin:20px 0 32px;">
                <h1 style="color:var(--text-primary);font-size:1.75rem;margin-bottom:8px;">Lupa Password?</h1>
                <p style="color:var(--text-secondary);font-size:.9375rem;line-height:1.6;">
                    Masukkan email kamu dan kami akan mengirimkan<br>kode OTP untuk reset password.
                </p>
            </div>

            {{-- ── Alert Error ── --}}
            @if($errors->any())
                <div class="fp-alert fp-alert-error">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <span>{{ $errors->first() }}</span>
                </div>
            @endif

            @if(session('error'))
                <div class="fp-alert fp-alert-error">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <span>{{ session('error') }}</span>
                </div>
            @endif

            {{-- ── Form ── --}}
            <form method="POST" action="{{ url('/user/forgot') }}" id="form-forgot">
                @csrf
                <div class="form-group" style="margin-bottom:12px;">
                    <label class="form-label form-label-dark" for="email-forgot">Alamat Email</label>
                    <div class="fp-input-wrap">
                        <span class="fp-input-icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        </span>
                        <input type="email" id="email-forgot" name="email" class="form-input form-input-dark fp-input"
                            placeholder="nama@email.com"
                            value="{{ old('email') }}"
                            autocomplete="email"
                            required autofocus>
                        <span class="fp-valid-icon" id="fp-email-valid" style="display:none;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0D9488" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        </span>
                    </div>
                </div>

                {{-- ── Info Box ── --}}
                <div class="fp-info-box">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <span>Kode OTP berlaku selama <strong>10 menit</strong>. Cek folder spam jika tidak ada di inbox.</span>
                </div>

                <button type="submit" class="btn btn-primary btn-lg btn-block" id="btn-send-otp" style="margin-top:28px;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                    Kirim Kode OTP
                </button>
            </form>

            <p style="color:var(--text-secondary);text-align:center;margin-top:24px;font-size:.875rem;">
                Ingat password? <a href="{{ url('/user/login') }}" style="color:var(--teal);font-weight:700;">Masuk sekarang</a>
            </p>

        </div>
    </div>

    <div class="auth-right">
        <div class="auth-brand">
            <div style="width:80px;height:80px;margin:0 auto 28px;background:rgba(255,255,255,.1);border-radius:24px;display:flex;align-items:center;justify-content:center;">
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            </div>
            <h2>Reset Password Aman</h2>
            <p style="margin-top:12px;">Verifikasi identitasmu melalui OTP yang dikirim ke email terdaftar. Proses cepat dan aman.</p>
            <div style="display:flex;gap:12px;justify-content:center;margin-top:32px;flex-wrap:wrap;">
                <div class="tag">🔐 Enkripsi End-to-End</div>
                <div class="tag">⚡ OTP Instan</div>
                <div class="tag">✅ Terverifikasi</div>
            </div>
        </div>
    </div>
</div>

{{-- ── Styles ── --}}
<style>
.fp-back-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 40px; height: 40px;
    background: rgba(26,45,66,.8);
    border: 1px solid var(--border-card);
    border-radius: var(--radius-md);
    color: var(--text-primary);
    transition: all .2s;
}
.fp-back-btn:hover { background: rgba(13,148,136,.15); border-color: rgba(13,148,136,.4); color: var(--teal); }

.fp-icon-wrap {
    width: 64px; height: 64px;
    border-radius: 18px;
    display: flex; align-items: center; justify-content: center;
}
.fp-icon-teal {
    background: rgba(13,148,136,.15);
    border: 1px solid rgba(13,148,136,.3);
    color: var(--teal);
}

.fp-alert {
    display: flex; align-items: center; gap: 10px;
    padding: 12px 16px;
    border-radius: var(--radius-md);
    font-size: .875rem; font-weight: 600;
    margin-bottom: 20px;
}
.fp-alert-error { background: rgba(239,68,68,.1); border: 1px solid rgba(239,68,68,.2); color: var(--red); }
.fp-alert-success { background: rgba(34,197,94,.1); border: 1px solid rgba(34,197,94,.2); color: var(--green); }

.fp-input-wrap { position: relative; }
.fp-input-icon {
    position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
    color: var(--text-secondary); pointer-events: none;
    display: flex; align-items: center;
}
.fp-valid-icon {
    position: absolute; right: 14px; top: 50%; transform: translateY(-50%);
    display: flex; align-items: center;
}
.fp-input { padding-left: 44px !important; padding-right: 40px !important; }

.fp-info-box {
    display: flex; align-items: flex-start; gap: 8px;
    padding: 12px 14px;
    background: rgba(13,148,136,.07);
    border-radius: var(--radius-md);
    color: var(--teal);
    font-size: .8125rem; line-height: 1.5;
    margin-top: 12px;
}
.fp-info-box svg { flex-shrink: 0; margin-top: 1px; }
</style>

<script>
const emailInput = document.getElementById('email-forgot');
const validIcon  = document.getElementById('fp-email-valid');

emailInput.addEventListener('input', function() {
    const valid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.value);
    validIcon.style.display = valid ? 'flex' : 'none';
});

document.getElementById('form-forgot').addEventListener('submit', function() {
    const btn = document.getElementById('btn-send-otp');
    btn.disabled = true;
    btn.innerHTML = `
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><circle cx="12" cy="12" r="10" opacity=".25"/><path d="M12 2a10 10 0 0 1 10 10" style="animation:spin .8s linear infinite;transform-origin:center"/></svg>
        Mengirim OTP...`;
});
</script>
</body>
</html>
