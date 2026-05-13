<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class AuthController extends Controller
{
    // ════════════════════════════════════════════════════
    // Login / Register / Logout
    // ════════════════════════════════════════════════════

    public function showLogin()
    {
        if (Auth::check()) return redirect('/user/dashboard');
        return view('web.auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|min:6',
        ]);

        if (Auth::attempt($request->only('email', 'password'), $request->boolean('remember'))) {
            $request->session()->regenerate();
            return redirect('/user/dashboard')->with('success', 'Login berhasil!');
        }

        return back()->withErrors(['email' => 'Email atau password salah'])->withInput();
    }

    public function showRegister()
    {
        if (Auth::check()) return redirect('/user/dashboard');
        return view('web.auth.register');
    }

    public function register(Request $request)
    {
        $request->validate([
            'name'            => 'required|string|max:255',
            'email'           => 'required|email|unique:users,email',
            'password'        => 'required|min:6|confirmed',
            'gender'          => 'required|in:Laki-laki,Perempuan',
            'tgl_lahir'       => 'required|date',
            'region'          => 'required|string',
            'education_level' => 'required|string',
            'daily_role'      => 'required|string',
            'income_level'    => 'required|string',
        ]);

        $dob = new \DateTime($request->tgl_lahir);
        $age = (new \DateTime())->diff($dob)->y;

        $user = User::create([
            'name'            => $request->name,
            'email'           => $request->email,
            'password'        => Hash::make($request->password),
            'gender'          => $request->gender,
            'tgl_lahir'       => $dob->format('Y-m-d H:i:s'),
            'age'             => $age,
            'region'          => $request->region,
            'education_level' => $request->education_level,
            'daily_role'      => $request->daily_role,
            'income_level'    => $request->income_level,
        ]);

        Auth::login($user);
        return redirect('/user/dashboard')->with('success', 'Registrasi berhasil! 🎉');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/user/login')->with('success', 'Berhasil logout');
    }

    // ════════════════════════════════════════════════════
    // Forgot Password — Step 1: Show form & send OTP
    // ════════════════════════════════════════════════════

    public function showForgotPassword()
    {
        return view('web.auth.forgot-password');
    }

    public function sendForgotOtp(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $user = User::where('email', $request->email)->first();

        // Generic response (prevent email enumeration)
        if (!$user) {
            session(['fp_email' => $request->email]);
            Log::info('FP: email not found — ' . $request->email);
            return redirect('/user/otp-verify')
                ->with('success', 'Jika email terdaftar, kode OTP telah dikirim.');
        }

        // Rate-limit: block if OTP still very fresh (< 60s)
        if ($user->fp_otp_expires_at) {
            $createdAt = Carbon::parse($user->fp_otp_expires_at)->subMinutes(10);
            if ($createdAt->diffInSeconds(now()) < 60) {
                return back()->withErrors(['email' => 'Harap tunggu 60 detik sebelum mengirim ulang OTP.']);
            }
        }

        // ── Generate OTP & save to MongoDB user document ──────────
        $otp     = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $expires = Carbon::now()->addMinutes(10);

        $user->update([
            'fp_otp'            => $otp,
            'fp_otp_expires_at' => $expires,
        ]);

        // Store email in session
        session(['fp_email' => $request->email]);

        Log::info("FP: OTP generated for {$user->email} — OTP: $otp (expires: $expires)");

        // ── Attempt to send email ──────────────────────────────────
        $emailSent = false;
        try {
            Mail::send('emails.otp', ['otp' => $otp, 'user' => $user], function ($m) use ($user) {
                $m->to($user->email, $user->name)
                  ->subject('Kode OTP Reset Password — ACTIVA');
            });
            $emailSent = true;
            Log::info("FP: Email OTP sent to {$user->email}");
        } catch (\Exception $e) {
            Log::error('FP: Email gagal — ' . $e->getMessage());
        }

        // Email tidak berhasil → tetap redirect ke otp-verify, OTP sudah tersimpan di MongoDB
        if (!$emailSent) {
            return redirect('/user/otp-verify')
                ->with('email_warning', 'Terjadi kendala pengiriman email. Jika tidak menerima OTP dalam 2 menit, klik Kirim Ulang.');
        }

        return redirect('/user/otp-verify')
            ->with('success', 'Kode OTP berhasil dikirim ke ' . $request->email);
    }

    // ════════════════════════════════════════════════════
    // Forgot Password — Step 2: Show & verify OTP
    // ════════════════════════════════════════════════════

    public function showOtpVerify()
    {
        if (!session('fp_email')) {
            return redirect('/user/forgot')->with('error', 'Sesi habis. Silakan ulangi.');
        }
        return view('web.auth.otp-verify');
    }

    public function verifyOtp(Request $request)
    {
        $request->validate(['otp' => 'required|string|size:6']);

        $email = session('fp_email');
        if (!$email) {
            return redirect('/user/forgot')->with('error', 'Sesi habis. Silakan ulangi.');
        }

        $user = User::where('email', $email)->first();

        if (!$user || !$user->fp_otp) {
            return back()->withErrors(['otp' => 'Kode OTP tidak valid atau sudah kedaluwarsa.']);
        }

        // Check expiry (10 minutes)
        if (!$user->fp_otp_expires_at || Carbon::parse($user->fp_otp_expires_at)->isPast()) {
            $user->update(['fp_otp' => null, 'fp_otp_expires_at' => null]);
            return back()->withErrors(['otp' => 'Kode OTP sudah kedaluwarsa. Silakan kirim ulang.']);
        }

        if ($user->fp_otp !== $request->otp) {
            return back()->withErrors(['otp' => 'Kode OTP salah. Periksa kembali email kamu.']);
        }

        // OTP valid — mark verified in session, clear from user doc
        $user->update(['fp_otp' => null, 'fp_otp_expires_at' => null]);
        session(['fp_otp_verified' => true]);

        return redirect('/user/reset-password');
    }

    // ════════════════════════════════════════════════════
    // Forgot Password — Resend OTP
    // ════════════════════════════════════════════════════

    public function resendOtp(Request $request)
    {
        $email = session('fp_email');
        if (!$email) {
            return redirect('/user/forgot')->with('error', 'Sesi habis. Silakan ulangi.');
        }

        $user = User::where('email', $email)->first();
        if (!$user) {
            return redirect('/user/otp-verify')->with('error', 'Email tidak ditemukan.');
        }

        $otp     = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $expires = Carbon::now()->addMinutes(10);

        $user->update([
            'fp_otp'            => $otp,
            'fp_otp_expires_at' => $expires,
        ]);

        $emailSent = false;
        try {
            Mail::send('emails.otp', ['otp' => $otp, 'user' => $user], function ($m) use ($user) {
                $m->to($user->email, $user->name)
                  ->subject('Kode OTP Reset Password — ACTIVA');
            });
            $emailSent = true;
            Log::info("FP Resend: Email OTP sent to {$user->email}");
        } catch (\Exception $e) {
            Log::error('FP Resend: Email gagal — ' . $e->getMessage());
        }

        if (!$emailSent) {
            return redirect('/user/otp-verify')
                ->with('email_warning', 'Terjadi kendala pengiriman email. Klik Kirim Ulang untuk mencoba lagi.');
        }

        return redirect('/user/otp-verify')
            ->with('success', 'Kode OTP baru telah dikirim ke ' . $email);
    }

    // ════════════════════════════════════════════════════
    // Forgot Password — Step 3: Reset password
    // ════════════════════════════════════════════════════

    public function showResetPassword()
    {
        if (!session('fp_email') || !session('fp_otp_verified')) {
            return redirect('/user/forgot')->with('error', 'Sesi tidak valid. Silakan ulangi proses.');
        }
        return view('web.auth.reset-password');
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'password' => 'required|min:8|confirmed|regex:/^(?=.*[a-zA-Z])(?=.*[0-9])/',
        ], [
            'password.regex' => 'Password harus mengandung huruf dan angka.',
        ]);

        $email = session('fp_email');
        if (!$email || !session('fp_otp_verified')) {
            return redirect('/user/forgot')->with('error', 'Sesi tidak valid. Silakan ulangi proses.');
        }

        $user = User::where('email', $email)->first();
        if (!$user) {
            return redirect('/user/forgot')->with('error', 'Email tidak ditemukan.');
        }

        // Update password
        $user->update(['password' => Hash::make($request->password)]);

        // Clean up session (fp_otp already cleared during verifyOtp step)
        $request->session()->forget(['fp_email', 'fp_otp_verified']);

        // Redirect langsung ke login dengan pesan sukses
        return redirect('/user/login')
            ->with('reset_success', true)
            ->with('success', 'Password berhasil direset! Silakan login dengan password baru.');
    }
}
