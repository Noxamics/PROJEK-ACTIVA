<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — ACTIVA</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="{{ asset('css/user-web/login.css') }}" rel="stylesheet">
</head>
<body>

    {{-- ══════════════════════════════════════════
         KIRI — Branding (dark navy)
    ══════════════════════════════════════════ --}}
    <div class="auth-left">

        {{-- Dekorasi lingkaran solid (visible, bukan pseudo-element) --}}
        <div class="deco-circle deco-circle-1"></div>
        <div class="deco-circle deco-circle-2"></div>
        <div class="deco-circle deco-circle-3"></div>

        <div class="auth-brand">

            {{-- Logo --}}
            <div class="logo-row">
                <img src="{{ asset('images/NewLogoEmblem2.svg') }}"
                     alt="ACTIVA logo"
                     class="logo-emblem"
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
                <h2>Selamat Datang<br>Kembali !</h2>
                <p>Masuk ke akun kamu untuk melihat<br>analisis gaya hidup digital.</p>
            </div>

            {{-- Tags --}}
            <div class="tags">
                <span class="tag"><i class="fas fa-robot"></i> Machine Learning</span>
                <span class="tag"><i class="fas fa-brain"></i> AI Recommendations</span>
                <span class="tag"><i class="fas fa-chart-line"></i> Visual Analytics</span>
            </div>

            {{-- Maskot --}}
            <div class="mascot-wrap">
                <img src="{{ asset('images/Maskot.png') }}"
                     alt="Maskot ACTIVA"
                     onerror="this.style.display='none'">
            </div>

        </div>
    </div>

    {{-- ══════════════════════════════════════════
         KANAN — Form putih dengan kurva kiri melengkung
    ══════════════════════════════════════════ --}}
    <div class="auth-right-wrap">

        {{--
            SVG Kurva Desktop:
            Path membentuk kurva cekung ke kiri — bagian putih "menggigit" ke dalam area gelap.
            viewBox lebar 100, kurva dari titik (100,0) melengkung ke (0, tengah) lalu balik ke (100, bawah).
        --}}
        <svg class="curve-svg"
             viewBox="0 0 100 1000"
             preserveAspectRatio="none"
             xmlns="http://www.w3.org/2000/svg">
            <path d="M100,0 C40,250 40,750 100,1000 L100,1000 L100,0 Z" fill="#ffffff"/>
        </svg>

        <div class="auth-right">
            <div class="auth-form-container">

                {{-- Logo kecil (khusus mobile, desktop disembunyikan via CSS) --}}
                <div class="form-logo-row">
                    <img src="{{ asset('images/NewLogoEmblem2.svg') }}"
                         alt="ACTIVA logo"
                         class="form-logo-emblem"
                         onerror="this.style.display='none'">
                    <div>
                        <div class="form-logo-name">ACTIVA</div>
                        <div class="form-logo-sub">DigitalLife Analyzer</div>
                    </div>
                </div>

                {{-- Heading form --}}
                <div class="form-heading">
                    <h1>Selamat Datang</h1>
                    <p>Masuk ke akun kamu untuk melihat analisis gaya hidup digital</p>
                </div>

                {{-- Alerts --}}
                @if(session('reset_success'))
                    <div class="reset-banner" id="login-success-banner">
                        <div class="reset-banner-icon">
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--teal)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                                <polyline points="22 4 12 14.01 9 11.01"/>
                            </svg>
                        </div>
                        <div style="font-size:.9375rem;font-weight:800;color:var(--text-primary);margin-bottom:5px;">Password Berhasil Direset! 🎉</div>
                        <div style="font-size:.8rem;color:var(--text-sec);">Silakan login dengan password baru kamu.</div>
                    </div>
                @elseif(session('success'))
                    <div class="alert alert-success">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                            <circle cx="12" cy="12" r="10"/><polyline points="9 12 12 15 16 10"/>
                        </svg>
                        <span>{{ session('success') }}</span>
                    </div>
                @endif

                @if($errors->any())
                    <div class="alert alert-error">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                            <circle cx="12" cy="12" r="10"/>
                            <line x1="12" y1="8" x2="12" y2="12"/>
                            <line x1="12" y1="16" x2="12.01" y2="16"/>
                        </svg>
                        <span>{{ $errors->first() }}</span>
                    </div>
                @endif

                {{-- Form --}}
                <form method="POST" action="{{ url('/user/login') }}" class="form-body">
                    @csrf

                    <div class="form-group">
                        <label class="form-label">Email</label>
                        <div class="input-wrap">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                                <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                                <polyline points="22,6 12,13 2,6"/>
                            </svg>
                            <input type="email" name="email" class="form-input"
                                   placeholder="masukkan email kamu"
                                   value="{{ old('email') }}" required autofocus>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Password</label>
                        <div class="input-wrap">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                            </svg>
                            <input type="password" name="password" class="form-input"
                                   placeholder="masukkan password" required>
                        </div>
                    </div>

                    <div class="forgot-row">
                        <a href="{{ url('/user/forgot') }}">Lupa Password?</a>
                    </div>

                    <button type="submit" class="btn-primary">Masuk</button>
                </form>

                {{-- Footer --}}
                <div class="form-footer">
                    <p>Belum punya akun? <a href="{{ url('/user/register') }}">Daftar sekarang</a></p>
                    <a href="{{ url('/user/landing') }}" class="back-link">← Kembali ke Beranda</a>
                </div>

            </div>
        </div>
    </div>

</body>
</html>