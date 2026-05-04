{{--
═══════════════════════════════════════════════
resources/views/auth/verify-otp.blade.php
Halaman Verifikasi OTP — Activa Admin
═══════════════════════════════════════════════
--}}
<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/svg+xml" href="{{ asset('../images/NewLogoEmblem2.svg') }}">
    <title>Verifikasi OTP — Activa Admin</title>
    <link
        href="https://fonts.googleapis.com/css2?family=DM+Serif+Display:ital@0;1&family=DM+Sans:wght@300;400;500;600;700&display=swap"
        rel="stylesheet">
    <style>
        :root {
            --navy: #1E3A5F;
            --navy-lt: #264875;
            --teal: #0D9488;
            --teal-dk: #0A7A6F;
            --teal-lt: rgba(13, 148, 136, 0.10);
            --ice: #F0F9FF;
            --white: #FFFFFF;
            --border: #E2EAF2;
            --border2: #C8D8EA;
            --red: #E05252;
            --red-lt: rgba(224, 82, 82, 0.10);
            --green: #16A34A;
            --green-lt: rgba(22, 163, 74, 0.10);
            --amber: #D97706;
            --amber-lt: rgba(217, 119, 6, 0.10);
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

        body {
            background: var(--ice);
            font-family: var(--sans);
            color: var(--text);
            min-height: 100vh;
            display: flex;
        }

        /* ── Split layout ── */
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

        .logo-img {
            width: 160px;
            height: 140px;
            object-fit: contain;
            margin-bottom: 90px;
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

        /* ── Right area ── */
        .right {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px;
        }

        .card {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 36px 32px;
            width: 100%;
            max-width: 420px;
            box-shadow: 0 4px 24px rgba(30, 58, 95, 0.10), 0 1px 4px rgba(30, 58, 95, 0.06);
            position: relative;
            overflow: hidden;
        }

        .card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--navy), var(--teal));
        }

        /* ── Alerts ── */
        .alert {
            border-radius: 10px;
            padding: 11px 14px;
            font-size: 13px;
            margin-bottom: 18px;
            display: flex;
            align-items: flex-start;
            gap: 9px;
            line-height: 1.5;
        }

        .alert-icon {
            font-size: 15px;
            flex-shrink: 0;
            margin-top: 1px;
        }

        .alert-success {
            background: var(--green-lt);
            border: 1px solid rgba(22, 163, 74, 0.2);
            color: var(--green);
        }

        .alert-error {
            background: var(--red-lt);
            border: 1px solid rgba(224, 82, 82, 0.2);
            color: var(--red);
        }

        .alert-amber {
            background: var(--amber-lt);
            border: 1px solid rgba(217, 119, 6, 0.2);
            color: var(--amber);
        }

        /* ── Card header ── */
        .card-title {
            font-family: var(--serif);
            font-size: 26px;
            color: var(--navy);
            margin-bottom: 6px;
            letter-spacing: -.3px;
        }

        .card-sub {
            font-size: 13px;
            color: var(--text2);
            line-height: 1.7;
            margin-bottom: 22px;
        }

        .card-sub strong {
            color: var(--teal);
            font-weight: 600;
        }

        /* ── Email badge ── */
        .email-badge {
            background: var(--ice);
            border: 1.5px solid var(--border2);
            border-radius: 8px;
            padding: 9px 14px;
            font-size: 13px;
            color: var(--navy);
            font-weight: 600;
            text-align: center;
            margin-bottom: 20px;
            font-family: monospace;
            letter-spacing: .02em;
        }

        /* ── OTP boxes ── */
        .otp-row {
            display: flex;
            gap: 8px;
            justify-content: center;
            margin-bottom: 6px;
        }

        .otp-box {
            width: 52px;
            height: 60px;
            background: var(--ice);
            border: 1.5px solid var(--border2);
            border-radius: 10px;
            text-align: center;
            font-size: 24px;
            font-weight: 700;
            color: var(--navy);
            font-family: var(--sans);
            outline: none;
            transition: all .2s;
            caret-color: var(--teal);
        }

        .otp-box:focus {
            border-color: var(--teal);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(13, 148, 136, 0.12);
        }

        .otp-box.filled {
            border-color: var(--teal);
            color: var(--teal);
            background: rgba(13, 148, 136, 0.04);
        }

        .otp-box.error {
            border-color: var(--red);
            background: var(--red-lt);
        }

        /* Hint di bawah kotak */
        .otp-hint {
            text-align: center;
            font-size: 11px;
            color: var(--text3);
            margin-bottom: 18px;
        }

        /* ── Timer ── */
        .timer-bar {
            background: var(--ice);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 10px 14px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .timer-label {
            font-size: 12px;
            color: var(--text2);
        }

        .timer-val {
            font-size: 14px;
            font-weight: 700;
            color: var(--navy);
            font-variant-numeric: tabular-nums;
        }

        .timer-val.danger {
            color: var(--red);
        }

        /* ── Progress bar ── */
        .prog-wrap {
            height: 3px;
            background: var(--border);
            border-radius: 99px;
            margin-bottom: 20px;
            overflow: hidden;
        }

        .prog-bar {
            height: 100%;
            background: var(--teal);
            border-radius: 99px;
            transition: width 1s linear, background .5s;
        }

        .prog-bar.danger {
            background: var(--red);
        }

        /* ── Buttons ── */
        .btn {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            font-family: var(--sans);
            cursor: pointer;
            transition: all .2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-teal {
            background: var(--teal);
            color: #fff;
            box-shadow: 0 4px 14px rgba(13, 148, 136, 0.3);
        }

        .btn-teal:hover:not(:disabled) {
            background: var(--teal-dk);
            transform: translateY(-1px);
        }

        .btn-teal:disabled {
            opacity: .5;
            cursor: not-allowed;
            transform: none;
        }

        .btn-ghost {
            background: none;
            border: 1.5px solid var(--border2);
            color: var(--text2);
            margin-top: 10px;
        }

        .btn-ghost:hover {
            border-color: var(--navy);
            color: var(--navy);
        }

        /* ── Divider ── */
        .divider {
            border: none;
            border-top: 1px solid var(--border);
            margin: 20px 0;
        }

        /* ── Resend ── */
        .resend-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 12px;
        }

        .resend-label {
            color: var(--text3);
        }

        .btn-resend {
            background: none;
            border: none;
            font-size: 12px;
            font-family: var(--sans);
            font-weight: 600;
            cursor: pointer;
            transition: color .2s;
            color: var(--text3);
        }

        .btn-resend:not(:disabled) {
            color: var(--teal);
        }

        .btn-resend:not(:disabled):hover {
            color: var(--teal-dk);
        }

        .btn-resend:disabled {
            cursor: default;
        }

        /* ── Dev mode box ── */
        .dev-box {
            background: #F0FFF4;
            border: 1.5px dashed #4ADE80;
            border-radius: 10px;
            padding: 16px;
            text-align: center;
            margin-bottom: 18px;
        }

        .dev-title {
            font-size: 11px;
            font-weight: 700;
            color: #16A34A;
            letter-spacing: .08em;
            text-transform: uppercase;
            margin-bottom: 8px;
        }

        .dev-otp {
            font-size: 36px;
            font-weight: 700;
            letter-spacing: 10px;
            color: #15803D;
            font-family: 'Courier New', monospace;
            cursor: pointer;
            transition: opacity .15s;
        }

        .dev-otp:hover {
            opacity: .7;
        }

        .dev-hint {
            font-size: 11px;
            color: #4A6180;
            margin-top: 6px;
        }

        /* ── Back link ── */
        .back-link {
            display: block;
            text-align: center;
            margin-top: 16px;
            font-size: 12px;
            color: var(--text3);
            text-decoration: none;
            transition: color .2s;
        }

        .back-link:hover {
            color: var(--navy);
        }

        @media (max-width: 768px) {
            .left {
                display: none;
            }

            .right {
                padding: 20px;
            }

            .otp-box {
                width: 44px;
                height: 52px;
                font-size: 20px;
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

        {{-- ── RIGHT CARD ── --}}
        <div class="right">
            <div class="card">

                {{-- Success: OTP terkirim --}}
                @if (session('success') === 'otp_sent')
                    <div class="alert alert-success">
                        <span class="alert-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none"
                                stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                                <polyline points="22 4 12 14.01 9 11.01" />
                            </svg>
                        </span>
                        <div><strong>Kode OTP berhasil dikirim!</strong> Cek inbox atau folder spam email kamu.</div>
                    </div>
                @endif

                {{-- Error messages --}}
                @if (session('error'))
                    @php $err = session('error'); @endphp
                    <div class="alert alert-error">
                        <span class="alert-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none"
                                stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10" />
                                <line x1="15" y1="9" x2="9" y2="15" />
                                <line x1="9" y1="9" x2="15" y2="15" />
                            </svg>
                        </span>
                        <div>
                            @if ($err === 'invalid_otp') <strong>Kode OTP salah.</strong> Silakan coba lagi.
                            @elseif ($err === 'expired') <strong>Kode OTP sudah kedaluwarsa.</strong> Minta kode baru.
                            @elseif ($err === 'rate_limit') <strong>Terlalu banyak percobaan.</strong> Tunggu sebentar.
                            @else <strong>Terjadi kesalahan.</strong> Silakan coba lagi.
                            @endif
                        </div>
                    </div>
                @endif

                @if ($errors->any())
                    <div class="alert alert-error">
                        <span class="alert-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none"
                                stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path
                                    d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
                                <line x1="12" y1="9" x2="12" y2="13" />
                                <line x1="12" y1="17" x2="12.01" y2="17" />
                            </svg>
                        </span>
                        <div>{{ $errors->first() }}</div>
                    </div>
                @endif

                {{-- Header --}}
                <div class="card-title">
                    Cek Email Anda
                </div>
                <div class="card-sub">Kode 6 digit dikirim ke:</div>

                <div class="email-badge">{{ session('otp_email') }}</div>

                {{-- Dev mode OTP display — HAPUS DI PRODUCTION --}}
                @if (isset($debugOtp) && $debugOtp)
                    <div class="dev-box">
                        <div class="dev-title">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
                                stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="16 18 22 12 16 6" />
                                <polyline points="8 6 2 12 8 18" />
                            </svg>
                            Mode Development
                        </div>
                        <div class="dev-otp" id="dev-otp" onclick="copyDevOTP('{{ $debugOtp }}')">{{ $debugOtp }}</div>
                        <div class="dev-hint">Klik kode untuk copy otomatis ke input</div>
                    </div>
                @endif

                {{-- OTP Form --}}
                <form method="POST" action="{{ route('admin.verify-otp.process') }}" id="otp-form">
                    @csrf

                    {{-- 6 Kotak OTP --}}
                    <div class="otp-row" id="otp-row">
                        @for ($i = 0; $i < 6; $i++) <input class="otp-box" type="text" maxlength="1" inputmode="numeric"
                            aut ocomplete="off" {{ $i === 0 ? 'autofocus' : '' }}>
                        @endfor
                    </div>
                    <div class="otp-hint">Ketik angka — kotak akan berpindah otomatis</div>

                    {{-- Input hidden yang dikirim ke server --}}
                    <input type="hidden" name="otp" id="otp-hidden">

                    {{-- Timer + Progress --}}
                    <div class="prog-wrap">
                        <div class="prog-bar" id="prog-bar" style="width: 100%"></div>
                    </div>
                    <div class="timer-bar">
                        <span class="timer-label">Kode kedaluwarsa dalam</span>
                        <span class="timer-val" id="countdown">5:00</span>
                    </div>

                    <button type="submit" class="btn btn-teal" id="btn-verify">
                        <span id="btn-text">Verifikasi &amp; Masuk</span>
                        <span>→</span>
                    </button>
                </form>

                <hr class="divider">

                {{-- Resend --}}
                <div class="resend-row">
                    <span class="resend-label">Tidak menerima kode?</span>
                    <form action=" {{ route('admin.send-otp') }}" method="POST" style="display:inline;"
                        id="resend-form"> @csrf
                        <input type="hidden" name="email" value="{{ session('otp_email') }}">
                        <button type="submit" class="btn-resend" id="btn-resend" disabled> Kirim ulang (<span
                                id="resend-timer">60</span>s)
                        </button>
                    </form>
                </div>

                <a href="{{ route('login') }}" class="back-link">← Ganti email</a>

            </div>
        </div>

    </div>

    <script>
        // ── OTP box logic ────────────────────────────────────────────────────
        const boxes = document.querySelectorAll('.otp-box');

        boxes.forEach((box, i) => {
            box.addEventListener('input', () => {
                box.value = box.value.replace(/\D/g, '').slice(-1);
                if (box.value) {
                    box.classList.add('filled');
                    box.classList.remove('error');
                    if (i < boxes.length - 1) boxes[i + 1].focus();
                } else {
                    box.classList.remove('filled');
                }
                // Auto submit kalau semua terisi
                if (Array.from(boxes).every(b => b.value)) {
                    setTimeout(() => submitOtp(), 300);
                }
            });

            box.addEventListener('keydown', e => {
                if (e.key === 'Backspace' && !box.value && i > 0) boxes[i - 1].focus();
                if (e.key === 'Enter') submitOtp();
            });

            // Support paste OTP sekaligus
            box.addEventListener('paste', e => {
                e.preventDefault();
                const pasted = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g, '');
                if (pasted.length >= 6) {
                    boxes.forEach((b, idx) => {
                        b.value = pasted[idx] || '';
                        b.classList.toggle('filled', !!b.value);
                    });
                    boxes[5].focus();
                    setTimeout(() => submitOtp(), 300);
                }
            });
        });

        function getOtpValue() {
            return Array.from(boxes).map(b => b.value).join('');
        }

        function submitOtp() {
            const otp = getOtpValue();
            if (otp.length < 6) {
                boxes.forEach(b => { if (!b.value) b.classList.add('error'); });
                return;
            }
            document.getElementById('otp-hidden').value = otp;
            document.getElementById('otp-form').submit();
        }

        document.getElementById('otp-form').addEventListener('submit', function (e) {
            e.preventDefault();
            submitOtp();
        });

        // ── Dev mode: copy OTP ke kotak ─────────────────────────────────────
        function copyDevOTP(otp) {
            otp.toString().split('').forEach((digit, i) => {
                if (boxes[i]) {
                    boxes[i].value = digit;
                    boxes[i].classList.add('filled');
                }
            });
            boxes[5].focus();
            document.getElementById('dev-otp').style.opacity = '.5';
            setTimeout(() => {
                document.getElementById('dev-otp').style.opacity = '1';
                submitOtp();
            }, 500);
        }

        // ── Countdown 5 menit ───────────────────────────────────────────────
        const TOTAL = 300;
        let timeLeft = TOTAL;
        const countEl = document.getElementById('countdown');
        const progEl = document.getElementById('prog-bar');
        const verifyBtn = document.getElementById('btn-verify');
        const btnText = document.getElementById('btn-text');

        const countTimer = setInterval(() => {
            timeLeft--;
            const m = Math.floor(timeLeft / 60);
            const s = timeLeft % 60;
            countEl.textContent = `${m}:${s.toString().padStart(2, '0')}`;

            const pct = (timeLeft / TOTAL) * 100;
            progEl.style.width = pct + '%';

            if (timeLeft <= 60) {
                countEl.classList.add('danger');
                progEl.classList.add('danger');
            }

            if (timeLeft <= 0) {
                clearInterval(countTimer);
                countEl.textContent = 'Kedaluwarsa';
                verifyBtn.disabled = true;
                btnText.textContent = 'Kode sudah kedaluwarsa';
                progEl.style.width = '0%';
            }
        }, 1000);

        // ── Resend cooldown 60 detik ─────────────────────────────────────────
        let resendLeft = 60;
        const resendBtn = document.getElementById('btn-resend');
        const resendEl = document.getElementById('resend-timer');

        const resendTimer = setInterval(() => {
            resendLeft--;
            resendEl.textContent = resendLeft;
            if (resendLeft <= 0) {
                clearInterval(resendTimer);
                resendBtn.disabled = false;
                resendBtn.innerHTML = 'Kirim ulang';
            }
        }, 1000);
    </script>

</body>

</html>