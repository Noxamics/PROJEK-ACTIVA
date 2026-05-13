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
</body>
</html>
