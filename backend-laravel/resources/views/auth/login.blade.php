{{--
═══════════════════════════════════════════════
PATH: resources/views/auth/login.blade.php
Halaman Login OTP Passwordless — Activa Admin
═══════════════════════════════════════════════
--}}
<!DOCTYPE html>
<html lang="id">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="csrf-token" content="{{ csrf_token() }}">
  <link rel="icon" type="image/svg+xml" href="{{ asset('../images/NewLogoEmblem2.svg') }}">
  <title>Login — Activa Admin</title>
  <link
    href="https://fonts.googleapis.com/css2?family=DM+Serif+Display:ital@0;1&family=DM+Sans:wght@300;400;500;600;700&display=swap"
    rel="stylesheet">
  <style>
    :root {
      --navy: #1E3A5F;
      --teal: #0D9488;
      --teal-dk: #0A7A6F;
      --teal-lt: rgba(13, 148, 136, 0.10);
      --ice: #F0F9FF;
      --white: #FFFFFF;
      --border: #E2EAF2;
      --border2: #C8D8EA;
      --red: #E05252;
      --red-lt: rgba(224, 82, 82, 0.10);
      --text: #0F1F35;
      --text2: #4A6180;
      --text3: #8BA3BE;
      --serif: 'DM Serif Display', serif;
      --sans: 'DM Sans', sans-serif;
    }

    *,
    *::before,
    *::after {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    html,
    body {
      height: 100%;
    }

    .logo-img {
      width: 160px;
      height: 140px;
      object-fit: contain;
      margin-bottom: 90px;
    }

    body {
      background: var(--ice);
      font-family: var(--sans);
      color: var(--text);
      min-height: 100vh;
      display: flex;
    }

    .split {
      display: flex;
      width: 100%;
      min-height: 100vh;
    }

    /* ── Left brand panel ── */
    .left {
      background: var(--navy);
      width: 420px;
      flex-shrink: 0;
      display: flex;
      flex-direction: column;
      justify-content: flex-start;
      gap: 10px;
      padding: 20px 40px 40px 40px;
      position: relative;
      overflow: hidden;
    }

    .left::before {
      content: '';
      position: absolute;
      bottom: -80px;
      right: -80px;
      width: 300px;
      height: 300px;
      background: rgba(13, 148, 136, .12);
      border-radius: 50%;
    }

    .left::after {
      content: '';
      position: absolute;
      top: -60px;
      left: -60px;
      width: 200px;
      height: 200px;
      background: rgba(255, 255, 255, .04);
      border-radius: 50%;
    }

    .brand {
      display: flex;
      align-items: center;
      gap: 12px;
      position: relative;
      z-index: 1;
    }

    .brand-tag {
      font-size: 10px;
      color: rgba(255, 255, 255, .4);
      letter-spacing: .1em;
      text-transform: uppercase;
    }

    .left-body {
      position: relative;
      z-index: 1;
      gap: 30px;
    }

    .left-headline {
      font-family: var(--serif);
      font-size: 34px;
      color: #fff;
      line-height: 1.25;
      letter-spacing: -.5px;
      margin-bottom: 14px;
    }

    .left-headline em {
      color: #5EEAD4;
      font-style: italic;
    }

    .left-desc {
      font-size: 13px;
      color: rgba(255, 255, 255, .6);
      line-height: 1.8;
      margin-bottom: 28px;
    }

    .feat-list {
      display: flex;
      flex-direction: column;
      gap: 11px;
    }

    .feat-item {
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 13px;
      color: rgba(255, 255, 255, .7);
    }

    .feat-dot {
      width: 22px;
      height: 22px;
      border-radius: 50%;
      background: rgba(13, 148, 136, .25);
      border: 1px solid rgba(13, 148, 136, .35);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 11px;
      color: #5EEAD4;
      flex-shrink: 0;
    }

    .left-foot {
      font-size: 11px;
      color: rgba(255, 255, 255, .25);
      letter-spacing: .05em;
      position: relative;
      margin-top: 230px;
      z-index: 1;
    }

    /* ── Right login area ── */
    .right {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 40px;
    }

    .login-card {
      background: var(--white);
      border: 1px solid var(--border);
      border-radius: 20px;
      padding: 36px 32px;
      width: 100%;
      max-width: 400px;
      box-shadow: 0 4px 24px rgba(30, 58, 95, .10), 0 1px 4px rgba(30, 58, 95, .06);
      position: relative;
      overflow: hidden;
    }

    .login-card::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 4px;
      background: linear-gradient(90deg, var(--navy), var(--teal));
    }

    .p-title {
      font-family: var(--serif);
      font-size: 22px;
      color: var(--text);
      margin-bottom: 6px;
    }

    .p-sub {
      font-size: 13px;
      color: var(--text2);
      line-height: 1.7;
      margin-bottom: 24px;
    }

    .field {
      margin-bottom: 16px;
    }

    .field label {
      display: block;
      font-size: 12px;
      font-weight: 600;
      color: var(--text2);
      margin-bottom: 6px;
      letter-spacing: .04em;
    }

    .field input {
      width: 100%;
      padding: 11px 14px;
      border: 1.5px solid var(--border2);
      border-radius: 10px;
      font-size: 14px;
      font-family: var(--sans);
      color: var(--text);
      background: var(--white);
      transition: border-color .2s, box-shadow .2s;
      outline: none;
    }

    .field input:focus {
      border-color: var(--teal);
      box-shadow: 0 0 0 3px rgba(13, 148, 136, .12);
    }

    .btn-cta {
      width: 100%;
      padding: 13px 20px;
      border: none;
      border-radius: 10px;
      font-size: 14px;
      font-weight: 600;
      font-family: var(--sans);
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: space-between;
      transition: opacity .2s, transform .1s;
      margin-top: 8px;
    }

    .btn-navy {
      background: var(--navy);
      color: #fff;
    }

    .btn-navy:hover {
      opacity: .9;
    }

    .btn-navy:active {
      transform: scale(.99);
    }

    .btn-navy:disabled {
      opacity: .6;
      cursor: not-allowed;
    }

    /* Alert box */
    .alert {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      padding: 12px 14px;
      border-radius: 10px;
      font-size: 13px;
      line-height: 1.5;
      margin-bottom: 18px;
    }

    .alert-error {
      background: var(--red-lt);
      border: 1px solid rgba(224, 82, 82, .25);
      color: #c0392b;
    }

    .alert-info {
      background: rgba(13, 148, 136, .08);
      border: 1px solid rgba(13, 148, 136, .25);
      color: var(--teal-dk);
    }

    /* Mobile */
    @media (max-width: 700px) {
      .left {
        display: none;
      }

      .right {
        padding: 24px;
      }
    }
  </style>
</head>

<body>
  <div class="split">

    {{-- ── LEFT BRAND PANEL ── --}}
    <div class="left">
      <div class="brand">
        <div class="brand-icon">
          <img src="../images/NewLogoPutih.svg" alt="Logo" class="logo-img">
        </div>
      </div>

      <div class="left-body">
        <div class="left-headline">
          Monitor &amp; kelola<br>
          <em>digital wellness</em><br>
          dengan mudah.
        </div>
        <div class="left-desc">
          Dashboard terpusat untuk memantau hasil ML, mengelola pengguna,
          dan mengatur rekomendasi berbasis aturan.
        </div>
      </div>

      <div class="left-foot">ACTIVA · MEASURE. IMPROVE. THRIVE.</div>
    </div>

    {{-- ── RIGHT LOGIN CARD ── --}}
    <div class="right">
      <div class="login-card">

        {{-- Flash messages --}}
        @if (session('error') === 'rate_limit')
          <div class="alert alert-error">
            <span>
              <!-- Clock Icon -->
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" stroke="currentColor"
                stroke-width="2" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10" />
                <polyline points="12 6 12 12 16 14" />
              </svg>
            </span>
            <div>OTP aktif masih berlaku. Tunggu minimal 1 menit sebelum kirim ulang.</div>
          </div>
        @elseif (session('error') === 'mail_failed')
          <div class="alert alert-error">
            <span>
              <!-- X Circle Icon -->
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" stroke="currentColor"
                stroke-width="2" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10" />
                <line x1="15" y1="9" x2="9" y2="15" />
                <line x1="9" y1="9" x2="15" y2="15" />
              </svg>
            </span>
            <div>Gagal mengirim email. Periksa konfigurasi SMTP.</div>
          </div>
        @elseif (session('info'))
          <div class="alert alert-info">
            <span>
              <!-- Mail Icon -->
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" stroke="currentColor"
                stroke-width="2" viewBox="0 0 24 24">
                <rect x="3" y="5" width="18" height="14" rx="2" />
                <polyline points="3 7 12 13 21 7" />
              </svg>
            </span>
            <div>{{ session('info') }}</div>
          </div>
        @endif

        <div class="p-title">Masuk ke Activa</div>
        <div class="p-sub">
          Masukkan email admin kamu. Kode OTP 6 digit akan dikirim ke inbox.
        </div>

        <form method="POST" action="{{ route('admin.send-otp') }}">
          @csrf
          <div class="field">
            <label>Email Admin</label>
            <input type="email" name="email" placeholder="admin@activa.id" autocomplete="email"
              value="{{ old('email') }}" required autofocus>
            @error('email')
              <div style="color:var(--red);font-size:12px;margin-top:4px;">{{ $message }}</div>
            @enderror
          </div>

          <button type="submit" class="btn-cta btn-navy">
            <span>Kirim Kode OTP</span>
            <span>→</span>
          </button>
        </form>

      </div>
    </div>

  </div>
</body>

</html>