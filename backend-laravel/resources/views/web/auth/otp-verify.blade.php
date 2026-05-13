<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verifikasi OTP — ACTIVA</title>
    <link href="{{ asset('css/web.css') }}" rel="stylesheet">
</head>
<body>
<div class="auth-page">
    <div class="auth-left">
        <div class="auth-form-container anim-fade">

            <a href="{{ url('/user/forgot') }}" class="fp-back-btn">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 5l-7 7 7 7"/></svg>
            </a>

            <div class="fp-icon-wrap fp-icon-amber" style="margin-top:24px;">
                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
            </div>

            <div style="margin:20px 0 28px;">
                <h1 style="color:var(--text-primary);font-size:1.75rem;margin-bottom:8px;">Cek Email Kamu</h1>
                <p style="color:var(--text-secondary);font-size:.9375rem;line-height:1.6;">
                    Kami mengirimkan kode OTP 6 digit ke<br>
                    <strong style="color:var(--teal-light);">{{ session('fp_email', 'email kamu') }}</strong>
                </p>
            </div>

            @if($errors->any())
                <div class="fp-alert fp-alert-error">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <span>{{ $errors->first() }}</span>
                </div>
            @endif

            @if(session('success'))
                <div class="fp-alert fp-alert-success">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><polyline points="9 12 12 15 16 10"/></svg>
                    <span>{{ session('success') }}</span>
                </div>
            @endif

            @if(session('error'))
                <div class="fp-alert fp-alert-error">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <span>{{ session('error') }}</span>
                </div>
            @endif

            @if(session('email_warning'))
                <div class="fp-alert" style="background:rgba(245,158,11,.1);border:1px solid rgba(245,158,11,.25);color:var(--amber);margin-bottom:20px;display:flex;align-items:center;gap:10px;padding:12px 16px;border-radius:var(--radius-md);font-size:.875rem;font-weight:600;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                    <span>{{ session('email_warning') }}</span>
                </div>
            @endif



            <form method="POST" action="{{ url('/user/otp-verify') }}" id="form-otp">
                @csrf
                <label class="form-label form-label-dark" style="display:block;margin-bottom:16px;">Masukkan Kode OTP</label>

                <div class="otp-grid">
                    @for($i = 0; $i < 6; $i++)
                        <input type="text" class="otp-box" id="otp-{{ $i }}"
                            maxlength="1" inputmode="numeric" pattern="[0-9]"
                            data-index="{{ $i }}">
                    @endfor
                </div>

                <input type="hidden" name="otp" id="otp-hidden">

                <div class="otp-countdown" id="otp-countdown">
                    <span>Kirim ulang OTP dalam <strong id="countdown-num">60</strong> detik</span>
                    <div class="progress-bar" style="margin-top:8px;">
                        <div class="progress-fill" id="countdown-bar" style="width:100%;"></div>
                    </div>
                </div>

                <div id="otp-resend" style="display:none;text-align:center;margin-bottom:16px;">
                    {{-- Tombol resend — submit via JS fetch ke form terpisah --}}
                    <button type="button" class="fp-resend-btn" id="btn-resend" onclick="submitResend()">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
                        Kirim Ulang OTP
                    </button>
                </div>

                <button type="submit" class="btn btn-primary btn-lg btn-block" id="btn-verify" disabled>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    Verifikasi OTP
                </button>
            </form>

            {{-- Form resend TERPISAH — di luar form OTP utama (valid HTML) --}}
            <form method="POST" action="{{ url('/user/forgot-resend') }}" id="form-resend" style="display:none;">
                @csrf
            </form>

        </div>
    </div>

    <div class="auth-right">
        <div class="auth-brand">
            <div style="width:80px;height:80px;margin:0 auto 28px;background:rgba(245,158,11,.15);border:1px solid rgba(245,158,11,.3);border-radius:24px;display:flex;align-items:center;justify-content:center;">
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#F59E0B" stroke-width="2" stroke-linecap="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
            </div>
            <h2>Verifikasi Identitas</h2>
            <p style="margin-top:12px;">Masukkan 6 digit kode OTP yang dikirim ke emailmu. Kode berlaku 10 menit.</p>
            <div style="display:flex;gap:12px;justify-content:center;margin-top:32px;flex-wrap:wrap;">
                <div class="tag">📧 Cek Inbox</div>
                <div class="tag">⏱ 10 Menit</div>
                <div class="tag">🔒 Aman</div>
            </div>
        </div>
    </div>
</div>

<style>
.fp-back-btn{display:inline-flex;align-items:center;justify-content:center;width:40px;height:40px;background:rgba(26,45,66,.8);border:1px solid var(--border-card);border-radius:var(--radius-md);color:var(--text-primary);transition:all .2s}
.fp-back-btn:hover{background:rgba(13,148,136,.15);border-color:rgba(13,148,136,.4);color:var(--teal)}
.fp-icon-wrap{width:64px;height:64px;border-radius:18px;display:flex;align-items:center;justify-content:center}
.fp-icon-amber{background:rgba(245,158,11,.15);border:1px solid rgba(245,158,11,.3);color:var(--amber)}
.fp-alert{display:flex;align-items:center;gap:10px;padding:12px 16px;border-radius:var(--radius-md);font-size:.875rem;font-weight:600;margin-bottom:20px}
.fp-alert-error{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.2);color:var(--red)}
.fp-alert-success{background:rgba(34,197,94,.1);border:1px solid rgba(34,197,94,.2);color:var(--green)}
.otp-grid{display:grid;grid-template-columns:repeat(6,1fr);gap:10px;margin-bottom:20px}
.otp-box{width:100%;height:58px;background:rgba(26,45,66,.6);border:2px solid var(--border-card);border-radius:var(--radius-md);color:var(--text-primary);font-size:1.375rem;font-weight:700;text-align:center;transition:all .2s;outline:none;caret-color:var(--teal)}
.otp-box:focus{border-color:var(--teal);box-shadow:0 0 0 4px rgba(13,148,136,.15)}
.otp-box.filled{border-color:var(--teal);background:rgba(13,148,136,.08)}
.otp-countdown{margin-bottom:16px}
.otp-countdown span{font-size:.8125rem;color:var(--text-secondary)}
.fp-resend-btn{display:inline-flex;align-items:center;gap:8px;padding:10px 20px;background:rgba(13,148,136,.1);border:1.5px solid rgba(13,148,136,.3);border-radius:var(--radius-md);color:var(--teal);font-size:.875rem;font-weight:600;cursor:pointer;transition:all .2s;font-family:inherit}
.fp-resend-btn:hover{background:rgba(13,148,136,.18);border-color:var(--teal)}

</style>

<script>
// ── Resend via standalone form (avoid nested form) ──────────────
function submitResend() {
    const btn = document.getElementById('btn-resend');
    btn.disabled = true;
    btn.innerHTML = '<div class="spinner" style="width:15px;height:15px;border-width:2px;"></div> Mengirim...';
    document.getElementById('form-resend').submit();
}

(function(){
    const boxes    = Array.from(document.querySelectorAll('.otp-box'));
    const hidden   = document.getElementById('otp-hidden');
    const btnVerify= document.getElementById('btn-verify');

    function checkComplete(){
        const val = boxes.map(b => b.value).join('');
        hidden.value = val;
        btnVerify.disabled = (val.length !== 6);
        boxes.forEach(b => b.classList.toggle('filled', b.value.length === 1));
    }

    boxes.forEach((box, idx) => {
        box.addEventListener('keydown', function(e){
            if(e.key === 'Backspace'){
                if(!this.value && idx > 0) boxes[idx-1].focus();
                this.value = '';
                checkComplete();
            }
        });
        box.addEventListener('input', function(){
            this.value = this.value.replace(/\D/g,'').slice(-1);
            checkComplete();
            if(this.value && idx < 5) boxes[idx+1].focus();
        });
        box.addEventListener('paste', function(e){
            e.preventDefault();
            const p = (e.clipboardData||window.clipboardData).getData('text').replace(/\D/g,'');
            p.split('').slice(0,6).forEach((c,i) => { if(boxes[i]) boxes[i].value = c; });
            checkComplete();
            const n = boxes.findIndex(b => !b.value);
            (n >= 0 ? boxes[n] : boxes[5]).focus();
        });
    });

    boxes[0].focus();

    // ── Countdown ───────────────────────────────────────────────
    let sec = 60;
    const num   = document.getElementById('countdown-num');
    const bar   = document.getElementById('countdown-bar');
    const cdDiv = document.getElementById('otp-countdown');
    const rsDiv = document.getElementById('otp-resend');

    const t = setInterval(() => {
        sec--;
        num.textContent = sec;
        bar.style.width = (sec / 60 * 100) + '%';
        if(sec <= 0){ clearInterval(t); cdDiv.style.display = 'none'; rsDiv.style.display = 'block'; }
    }, 1000);

    // ── Submit handler ──────────────────────────────────────────
    document.getElementById('form-otp').addEventListener('submit', function(){
        checkComplete();
        btnVerify.disabled = true;
        btnVerify.innerHTML = '<div class="spinner" style="width:18px;height:18px;border-width:2px;"></div> Memverifikasi...';
    });
})();
</script>
</body>
</html>
