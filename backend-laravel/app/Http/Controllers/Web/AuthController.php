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

    /**
     * Step A — Frontend mengirim Google id_token → backend verifikasi → simpan di session.
     */
    public function verifyGoogleToken(Request $request)
    {
        $request->validate(['id_token' => 'required|string']);

        try {
            $response = \Illuminate\Support\Facades\Http::get('https://oauth2.googleapis.com/tokeninfo', [
                'id_token' => $request->id_token,
            ]);

            if (!$response->ok()) {
                return response()->json(['success' => false, 'message' => 'Token tidak valid.'], 422);
            }

            $payload = $response->json();

            $allowedAud = env('GOOGLE_CLIENT_ID', '');
            if ($allowedAud && !in_array($payload['aud'] ?? '', [$allowedAud])) {
                return response()->json(['success' => false, 'message' => 'Token tidak valid untuk aplikasi ini.'], 422);
            }

            if (($payload['email_verified'] ?? 'false') !== 'true') {
                return response()->json(['success' => false, 'message' => 'Email Google belum diverifikasi.'], 422);
            }

            $email = $payload['email'];
            $name  = $payload['name'] ?? '';

            if (User::where('email', $email)->exists()) {
                return response()->json([
                    'success'        => false,
                    'message'        => 'Email ini sudah terdaftar. Silakan login.',
                    'already_exists' => true,
                ], 409);
            }

            session([
                'reg_google_verified' => true,
                'reg_google_email'    => $email,
                'reg_google_name'     => $name,
                'reg_google_picture'  => $payload['picture'] ?? null,
            ]);

            return response()->json([
                'success' => true,
                'email'   => $email,
                'name'    => $name,
                'picture' => $payload['picture'] ?? null,
            ]);
        } catch (\Exception $e) {
            Log::error('Google token verify failed: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Gagal memverifikasi. Coba lagi.'], 500);
        }
    }

    public function register(Request $request)
    {
        if (!session('reg_google_verified') || !session('reg_google_email')) {
            return back()->withErrors(['google' => 'Verifikasi Google wajib dilakukan sebelum mendaftar.'])->withInput();
        }

        $googleEmail = session('reg_google_email');

        $request->validate([
            'name'            => 'required|string|max:255|min:3',
            'password'        => ['required', 'min:8', 'confirmed', 'regex:/^(?=.*[a-zA-Z])(?=.*[0-9])/'],
            'gender'          => 'required|in:Male,Female',
            'tgl_lahir'       => 'required|date|before:-10 years',
            'region'          => 'required|in:Africa,Asia,Europe,Middle East,North America,South America',
            'education_level' => 'required|in:High School,Bachelor,Master,PhD',
            'daily_role'      => 'required|in:Student,Full-time,Part-time,Caregiver,Unemployed',
            'income_level'    => 'required|in:Low,Lower-Mid,Upper-Mid,High',
        ], [
            'password.regex'   => 'Password harus mengandung huruf dan angka.',
            'password.min'     => 'Password minimal 8 karakter.',
            'tgl_lahir.before' => 'Umur minimal 10 tahun.',
            'name.min'         => 'Nama minimal 3 karakter.',
            'gender.in'        => 'Pilih jenis kelamin yang valid.',
            'region.in'        => 'Pilih wilayah yang valid.',
            'education_level.in' => 'Pilih pendidikan yang valid.',
            'daily_role.in'    => 'Pilih peran harian yang valid.',
            'income_level.in'  => 'Pilih tingkat pendapatan yang valid.',
        ]);

        if (User::where('email', $googleEmail)->exists()) {
            session()->forget(['reg_google_verified', 'reg_google_email', 'reg_google_name', 'reg_google_picture']);
            return redirect('/user/login')->withErrors(['email' => 'Email sudah terdaftar. Silakan login.']);
        }

        $dob = new \DateTime($request->tgl_lahir);
        $age = (new \DateTime())->diff($dob)->y;

        $user = User::create([
            'name'            => $request->name,
            'email'           => $googleEmail,
            'password'        => Hash::make($request->password),
            'gender'          => $request->gender,
            'tgl_lahir'       => $dob->format('Y-m-d H:i:s'),
            'age'             => $age,
            'region'          => $request->region,
            'education_level' => $request->education_level,
            'daily_role'      => $request->daily_role,
            'income_level'    => $request->income_level,
        ]);

        session()->forget(['reg_google_verified', 'reg_google_email', 'reg_google_name', 'reg_google_picture']);

        Auth::login($user);
        return redirect('/user/dashboard')->with('success', 'Registrasi berhasil! Selamat datang 🎉');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/user/landing')->with('success', 'Berhasil logout');
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

        if (!$user) {
            session(['fp_email' => $request->email]);
            Log::info('FP: email not found — ' . $request->email);
            return redirect('/user/otp-verify')
                ->with('success', 'Jika email terdaftar, kode OTP telah dikirim.');
        }

        $otp     = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $expires = Carbon::now()->addMinutes(10);

        $user->update([
            'fp_otp'            => $otp,
            'fp_otp_expires_at' => $expires,
        ]);

        session(['fp_email' => $request->email]);

        $emailSent = false;
        try {
            Mail::to($request->email)->send(new \App\Mail\ForgotPasswordOtp($user, $otp));
            $emailSent = true;
            Log::info('FP: OTP sent to ' . $request->email);
        } catch (\Exception $e) {
            Log::error('FP: Email gagal — ' . $e->getMessage());
        }

        if (!$emailSent) {
            return redirect('/user/otp-verify')
                ->with('email_warning', 'Terjadi kendala pengiriman email. Jika tidak menerima OTP dalam 2 menit, klik Kirim Ulang.');
        }

        return redirect('/user/otp-verify')
            ->with('success', 'Kode OTP berhasil dikirim ke ' . $request->email);
    }

    // ════════════════════════════════════════════════════
    // Forgot Password — Step 2: Verify OTP
    // ════════════════════════════════════════════════════

    public function showOtpVerify()
    {
        if (!session('fp_email')) return redirect('/user/forgot');
        return view('web.auth.otp-verify');
    }

    public function verifyOtp(Request $request)
    {
        $request->validate(['otp' => 'required|string|size:6']);

        $email = session('fp_email');
        if (!$email) return redirect('/user/forgot');

        $user = User::where('email', $email)->first();

        if (!$user || !$user->fp_otp) {
            return back()->withErrors(['otp' => 'Sesi OTP tidak ditemukan. Mulai ulang proses lupa password.']);
        }

        if (Carbon::now()->greaterThan(Carbon::parse($user->fp_otp_expires_at))) {
            return back()->withErrors(['otp' => 'Kode OTP sudah kedaluwarsa. Klik Kirim Ulang.']);
        }

        if ($request->otp !== $user->fp_otp) {
            return back()->withErrors(['otp' => 'Kode OTP salah. Periksa kembali email kamu.']);
        }

        session(['fp_otp_verified' => true]);

        return redirect('/user/reset-password');
    }

    public function resendOtp(Request $request)
    {
        $email = session('fp_email');
        if (!$email) return redirect('/user/forgot');

        $user = User::where('email', $email)->first();
        if (!$user) return redirect('/user/forgot');

        $otp     = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $expires = Carbon::now()->addMinutes(10);

        $user->update([
            'fp_otp'            => $otp,
            'fp_otp_expires_at' => $expires,
        ]);

        $emailSent = false;
        try {
            Mail::to($email)->send(new \App\Mail\ForgotPasswordOtp($user, $otp));
            $emailSent = true;
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
    // Forgot Password — Step 3: Reset Password
    // ════════════════════════════════════════════════════

    public function showResetPassword()
    {
        if (!session('fp_email') || !session('fp_otp_verified')) {
            return redirect('/user/forgot');
        }
        return view('web.auth.reset-password');
    }

    public function resetPassword(Request $request)
    {
        if (!session('fp_email') || !session('fp_otp_verified')) {
            return redirect('/user/forgot');
        }

        $request->validate([
            'password' => 'required|min:8|confirmed',
        ], [
            'password.min'       => 'Password minimal 8 karakter.',
            'password.confirmed' => 'Konfirmasi password tidak cocok.',
        ]);

        $email = session('fp_email');
        $user  = User::where('email', $email)->first();

        if (!$user) return redirect('/user/forgot');

        $user->update([
            'password'          => Hash::make($request->password),
            'fp_otp'            => null,
            'fp_otp_expires_at' => null,
        ]);

        session()->forget(['fp_email', 'fp_otp_verified']);

        return redirect('/user/login')->with('reset_success', true);
    }
}
