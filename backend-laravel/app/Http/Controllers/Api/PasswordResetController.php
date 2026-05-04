<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PasswordReset;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;

/**
 * PasswordResetController
 * ─────────────────────────────────────────────────────
 * Flow reset password via OTP:
 *
 *  1. POST /api/auth/forgot-password   → kirim OTP ke email
 *  2. POST /api/auth/verify-otp        → verifikasi kode OTP
 *  3. POST /api/auth/reset-password    → set password baru
 */
class PasswordResetController extends Controller
{
    /**
     * STEP 1 — POST /api/auth/forgot-password
     * Kirim kode OTP 6 digit ke email user
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $user = User::where('email', $request->email)->first();

        // Selalu return 200 meski email tidak ada (security: jangan bocorkan email)
        if (! $user) {
            return response()->json([
                'success' => true,
                'message' => 'Jika email terdaftar, kode OTP telah dikirim',
            ]);
        }

        try {
            // Hapus OTP lama jika ada
            PasswordReset::where('email', $request->email)->delete();

            $otpCode = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

            // Simpan OTP sebagai plain text (lebih reliable untuk OTP yang short-lived)
            PasswordReset::create([
                'email'      => $request->email,
                'otp_code'   => $otpCode,  // Plain text, tidak di-hash
                'expired_at' => now()->addMinutes(10),
                'verified'   => false,
            ]);

            // Kirim email OTP
            Mail::send('emails.otp', ['otp' => $otpCode, 'user' => $user], function ($m) use ($user) {
                $m->to($user->email, $user->name)
                  ->subject('Kode OTP Reset Password');
            });

            return response()->json([
                'success' => true,
                'message' => 'Kode OTP telah dikirim ke email Anda (berlaku 10 menit)',
            ]);
        } catch (\Exception $e) {
            // Log error untuk debugging
            Log::error('Failed to send OTP email', [
                'email' => $request->email,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Gagal mengirim OTP. ' . ($e->getMessage() ?: 'Silakan cek konfigurasi email'),
            ], 500);
        }
    }

    /**
     * STEP 2 — POST /api/auth/verify-otp
     * Verifikasi kode OTP, return token sementara untuk reset
     */
    public function verifyOtp(Request $request): JsonResponse
    {
        $request->validate([
            'email'    => 'required|email',
            'otp_code' => 'required|string|size:6',
        ]);

        $record = PasswordReset::where('email', $request->email)
            ->where('verified', false)
            ->first();

        if (! $record) {
            return response()->json([
                'success' => false,
                'message' => 'Permintaan OTP tidak ditemukan atau sudah digunakan',
            ], 404);
        }

        if (now()->isAfter($record->expired_at)) {
            $record->delete();
            return response()->json([
                'success' => false,
                'message' => 'Kode OTP sudah expired, silakan minta ulang',
            ], 410);
        }

        // Bandingkan OTP langsung (plain text comparison)
        if (trim($request->otp_code) !== trim($record->otp_code)) {
            return response()->json([
                'success' => false,
                'message' => 'Kode OTP salah',
            ], 422);
        }

        // Tandai OTP sudah diverifikasi
        $record->update(['verified' => true]);

        return response()->json([
            'success' => true,
            'message' => 'OTP valid, silakan set password baru',
            'data'    => ['email' => $request->email],
        ]);
    }

    /**
     * STEP 3 — POST /api/auth/reset-password
     * Set password baru (hanya boleh setelah OTP diverifikasi)
     */
    public function resetPassword(Request $request): JsonResponse
    {
        $request->validate([
            'email'                 => 'required|email',
            'password'              => 'required|string|min:8|confirmed',
            'password_confirmation' => 'required',
        ]);

        $record = PasswordReset::where('email', $request->email)
            ->where('verified', true)
            ->first();

        if (! $record) {
            return response()->json([
                'success' => false,
                'message' => 'Verifikasi OTP belum dilakukan atau sudah digunakan',
            ], 403);
        }

        $user = User::where('email', $request->email)->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan',
            ], 404);
        }

        try {
            $user->update(['password' => Hash::make($request->password)]);

            // Hapus record OTP setelah berhasil
            $record->delete();

            return response()->json([
                'success' => true,
                'message' => 'Password berhasil direset, silakan login dengan password baru',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mereset password: ' . $e->getMessage(),
            ], 500);
        }
    }
}