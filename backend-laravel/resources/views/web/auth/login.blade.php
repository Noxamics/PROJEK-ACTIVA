<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — ACTIVA</title>
    <link href="{{ asset('css/web.css') }}" rel="stylesheet">
</head>
<body>
<div class="auth-page">
    <div class="auth-left">
        <div class="auth-form-container anim-fade">
            <div style="margin-bottom:36px;">
                <div style="display:flex;align-items:center;gap:12px;margin-bottom:24px;">
                    <div class="sidebar-logo"><svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round"><path d="M9 11l3 3L22 4"/></svg></div>
                    <div>
                        <div style="color:var(--text-primary);font-size:1.25rem;font-weight:800;">ACTIVA</div>
                        <div style="color:var(--text-secondary);font-size:.6875rem;font-weight:600;letter-spacing:.05em;text-transform:uppercase;">DigitalLife Analyzer</div>
                    </div>
                </div>
                <h1 style="color:var(--text-primary);margin-bottom:8px;">Selamat Datang</h1>
                <p style="color:var(--text-secondary);font-size:.9375rem;">Masuk ke akun kamu untuk melihat analisis gaya hidup digital</p>
            </div>

            @if(session('reset_success'))
                {{-- ── Banner sukses reset password ── --}}
                <div class="login-success-banner" id="login-success-banner">
                    <div style="width:52px;height:52px;margin:0 auto 14px;background:rgba(13,148,136,.15);border-radius:50%;display:flex;align-items:center;justify-content:center;border:2px solid rgba(13,148,136,.3);">
                        <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="var(--teal)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    </div>
                    <div style="font-size:1rem;font-weight:800;color:var(--text-primary);margin-bottom:6px;">Password Berhasil Direset! 🎉</div>
                    <div style="font-size:.8125rem;color:var(--text-secondary);line-height:1.5;">Silakan login dengan password baru kamu.</div>
                </div>
            @elseif(session('success'))
                <div style="padding:12px 16px;background:rgba(34,197,94,.1);border:1px solid rgba(34,197,94,.2);border-radius:var(--radius-md);margin-bottom:20px;display:flex;align-items:center;gap:10px;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--green)" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><polyline points="9 12 12 15 16 10"/></svg>
                    <p style="color:var(--green);font-size:.875rem;font-weight:600;">{{ session('success') }}</p>
                </div>
            @endif

            @if($errors->any())
                <div style="padding:12px 16px;background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.2);border-radius:var(--radius-md);margin-bottom:20px;">
                    <p style="color:var(--red);font-size:.875rem;font-weight:600;">{{ $errors->first() }}</p>
                </div>
            @endif

            <form method="POST" action="{{ url('/user/login') }}" style="display:flex;flex-direction:column;gap:20px;">
                @csrf
                <div class="form-group">
                    <label class="form-label form-label-dark">Email</label>
                    <input type="email" name="email" class="form-input form-input-dark" placeholder="masukkan email kamu" value="{{ old('email') }}" required autofocus>
                </div>
                <div class="form-group">
                    <label class="form-label form-label-dark">Password</label>
                    <input type="password" name="password" class="form-input form-input-dark" placeholder="masukkan password" required>
                </div>
                <div style="display:flex;justify-content:flex-end;">
                    <a href="{{ url('/user/forgot') }}" style="color:var(--teal);font-size:.8125rem;font-weight:600;">Lupa Password?</a>
                </div>
                <button type="submit" class="btn btn-primary btn-lg btn-block">Masuk</button>
            </form>

            <p style="color:var(--text-secondary);text-align:center;margin-top:28px;font-size:.875rem;">
                Belum punya akun? <a href="{{ url('/user/register') }}" style="color:var(--teal);font-weight:700;">Daftar sekarang</a>
            </p>
            <p style="color:var(--text-secondary);text-align:center;margin-top:12px;font-size:.8125rem;">
                <a href="{{ url('/user/landing') }}" style="color:var(--text-secondary);font-weight:600;transition:color .2s;" onmouseover="this.style.color='var(--teal)'" onmouseout="this.style.color='var(--text-secondary)'">← Kembali ke Beranda</a>
            </p>
        </div>
    </div>

    <div class="auth-right">
        <div class="auth-brand">
            <div style="width:80px;height:80px;margin:0 auto 28px;background:rgba(255,255,255,.1);border-radius:24px;display:flex;align-items:center;justify-content:center;">
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
            </div>
            <h2>Analisis Gaya Hidup Digital</h2>
            <p style="margin-top:12px;">Kenali pola penggunaan digitalmu, dapatkan prediksi berbasis Machine Learning, dan rekomendasi personal dari AI.</p>
            <div style="display:flex;gap:12px;justify-content:center;margin-top:32px;flex-wrap:wrap;">
                <div class="tag">🤖 Machine Learning</div>
                <div class="tag">🧠 AI Recommendations</div>
                <div class="tag">📊 Visual Analytics</div>
            </div>
        </div>
    </div>
</div>
<style>
.login-success-banner {
    background: rgba(13, 148, 136, 0.08);
    border: 1.5px solid rgba(13, 148, 136, 0.3);
    border-radius: 16px;
    padding: 20px;
    text-align: center;
    margin-bottom: 24px;
    animation: bannerIn .5s ease;
}
@keyframes bannerIn {
    from { opacity: 0; transform: translateY(-10px); }
    to   { opacity: 1; transform: translateY(0); }
}
</style>
</body>
</html>
