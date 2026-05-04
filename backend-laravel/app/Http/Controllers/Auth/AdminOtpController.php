<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Session;

/**
 * PATH: app/Http/Controllers/Auth/AdminOtpController.php
 *
 * Alur login admin (passwordless, session-based):
 *   1. GET  /admin/login           → showLogin()
 *   2. POST /admin/send-otp        → sendOtp()      → kirim OTP ke email
 *   3. GET  /admin/verify-otp      → showVerify()
 *   4. POST /admin/verify-otp      → verifyOtp()    → set session → redirect dashboard
 *   5. POST /admin/logout          → logout()
 *
 * Email admin ditentukan dari ENV: ADMIN_EMAIL
 */
class AdminOtpController extends Controller
{
    // ── 1. Tampilkan halaman login ──────────────────────────────────────
    public function showLogin()
    {
        // Jika sudah login, langsung ke dashboard
        if (Session::has('admin_id')) {
            return redirect('/admin/dashboard');
        }

        return view('auth.login');
    }

    // ── 2. Kirim OTP ke email admin ─────────────────────────────────────
    public function sendOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $email = trim(strtolower($request->input('email')));

        // Validasi: hanya email yang terdaftar di .env yang boleh login
        $allowedEmail = strtolower(trim(env('ADMIN_EMAIL', '')));
        if ($email !== $allowedEmail) {
            // Pesan generik agar tidak bisa ditebak email mana yang valid
            return redirect()->route('login')
                ->with('info', 'Jika email terdaftar sebagai admin, kode OTP akan segera dikirim.');
        }

        // Cari atau buat record admin di DB
        $admin = Admin::where('email', $email)->where('is_active', true)->first();

        if (!$admin) {
            // Admin belum ada di DB — buat otomatis dari ENV
            $admin = Admin::create([
                'full_name' => env('ADMIN_NAME', 'Administrator'),
                'email' => $email,
                'is_active' => true,
            ]);
        }

        // Rate limit: blokir jika OTP aktif dibuat < 60 detik lalu
        if ($admin->otp_expires_at) {
            // otp_expires_at = waktu dibuat + 5 menit → waktu dibuat = expires_at - 300 detik
            $createdAt = strtotime($admin->otp_expires_at) - 300;
            if (time() - $createdAt < 60) {
                return redirect()->route('login')
                    ->with('error', 'rate_limit');
            }
        }

        // Generate OTP 6 digit
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $otpExpiry = now()->addMinutes(5)->toDateTimeString();

        $admin->update([
            'otp_code' => $otp,
            'otp_expires_at' => $otpExpiry,
        ]);

        // Simpan email di session untuk halaman verify
        Session::put('otp_email', $email);
        Session::put('otp_admin_id', (string) $admin->_id);

        $mailSent = $this->sendOtpEmail($email, $otp, $admin->full_name ?? 'Admin');

        if ($mailSent) {
            return redirect()->route('admin.verify-otp')
                ->with('success', 'otp_sent');
        }

        // Fallback development — HAPUS DI PRODUCTION
        // Uncomment baris di bawah hanya saat testing lokal tanpa SMTP:
        // return redirect()->route('admin.verify-otp', ['debug_otp' => $otp])
        //     ->with('success', 'otp_sent');

        return redirect()->route('login')
            ->with('error', 'mail_failed');
    }

    // ── 3. Tampilkan halaman verifikasi OTP ─────────────────────────────
    public function showVerify(Request $request)
    {
        if (!Session::has('otp_email')) {
            return redirect()->route('login')->with('error', 'unauthorized');
        }

        // debug_otp hanya untuk development — hapus di production
        $debugOtp = app()->isLocal() ? $request->query('debug_otp') : null;

        return view('auth.verify-otp', compact('debugOtp'));
    }

    // ── 4. Proses verifikasi OTP ─────────────────────────────────────────
    public function verifyOtp(Request $request)
    {
        if (!Session::has('otp_email')) {
            return redirect()->route('login')->with('error', 'unauthorized');
        }

        $request->validate([
            'otp' => 'required|regex:/^[0-9]{6}$/',
        ], [
            'otp.regex' => 'Format OTP harus 6 digit angka.',
        ]);

        $email = Session::get('otp_email');
        $otp = trim($request->input('otp'));

        $admin = Admin::where('email', $email)
            ->where('otp_code', $otp)
            ->where('is_active', true)
            ->first();

        // OTP tidak cocok
        if (!$admin) {
            return redirect()->route('admin.verify-otp')
                ->with('error', 'invalid_otp');
        }

        // OTP expired
        if (!$admin->otp_expires_at || strtotime($admin->otp_expires_at) <= time()) {
            return redirect()->route('admin.verify-otp')
                ->with('error', 'expired');
        }

        // ✅ OTP valid — set session admin
        Session::put('admin_id', (string) $admin->_id);
        Session::put('admin_name', $admin->full_name ?? 'Admin');
        Session::put('admin_email', $admin->email);

        // Hapus OTP dari DB setelah berhasil dipakai
        $admin->update([
            'otp_code' => null,
            'otp_expires_at' => null,
        ]);

        // Bersihkan session sementara
        Session::forget(['otp_email', 'otp_admin_id']);

        return redirect('/admin/dashboard');
    }

    // ── 5. Logout ────────────────────────────────────────────────────────
    public function logout(Request $request)
    {
        Session::flush();
        return redirect()->route('login')->with('success', 'logged_out');
    }

    // ── Private: Kirim email OTP ──────────────────────────────────────────
    private function sendOtpEmail(string $to, string $otp, string $adminName): bool
    {
        try {
            Mail::send([], [], function ($mail) use ($to, $otp, $adminName) {
                $mail->to($to)
                    ->subject('[Activa] Kode OTP Login Admin — ' . date('H:i'))
                    ->html($this->buildEmailHtml($otp, $adminName));
            });

            return true;
        } catch (\Exception $e) {
            Log::error('Activa OTP email gagal: ' . $e->getMessage());
            return false;
        }
    }

    private function buildEmailHtml(string $otp, string $adminName): string
    {
        $year = date('Y');
        return <<<HTML
        <!DOCTYPE html>
        <html lang="id">
        <head><meta charset="UTF-8"><title>OTP Activa</title></head>
        <body style="margin:0;padding:20px;background:#F0F9FF;font-family:'Segoe UI',sans-serif;">
          <div style="max-width:520px;margin:0 auto;background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(30,58,95,.10);">
            <div style="background:#1E3A5F;padding:32px;text-align:center;">
              <div style="font-size:22px;font-weight:700;color:#fff;">Activa Admin</div>
              <div style="font-size:13px;color:rgba(255,255,255,.6);margin-top:6px;">Kode OTP Login Aman</div>
            </div>
            <div style="padding:32px;">
              <p style="color:#0F1F35;font-size:15px;line-height:1.7;margin:0 0 14px;">
                Halo, <strong>{$adminName}</strong>!
              </p>
              <p style="color:#0F1F35;font-size:15px;line-height:1.7;margin:0 0 14px;">
                Gunakan kode di bawah untuk masuk ke panel admin Activa:
              </p>
              <div style="background:#F0F9FF;border:2px solid #0D9488;border-radius:12px;text-align:center;padding:24px;margin:24px 0;">
                <div style="font-size:44px;font-weight:700;letter-spacing:12px;color:#0D9488;font-family:'Courier New',monospace;">{$otp}</div>
                <div style="font-size:12px;color:#4A6180;margin-top:10px;">Berlaku selama <strong>5 menit</strong></div>
              </div>
              <div style="background:#FFF8EC;border-left:4px solid #F59E0B;border-radius:6px;padding:14px 16px;font-size:13px;color:#92400E;margin:20px 0;">
                Jangan bagikan kode ini ke siapa pun. Tim Activa tidak akan pernah memintanya.
              </div>
              <p style="color:#4A6180;font-size:13px;">Jika kamu tidak mencoba login, abaikan email ini.</p>
            </div>
            <div style="background:#F0F9FF;border-top:1px solid #E2EAF2;padding:16px;text-align:center;font-size:11px;color:#8BA3BE;">
              © {$year} Activa · Sistem Monitoring Digital Wellness
            </div>
          </div>
        </body>
        </html>
        HTML;
    }
}