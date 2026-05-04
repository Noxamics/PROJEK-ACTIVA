<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\RegisterRequest;
use App\Http\Requests\LoginRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;

class AuthController extends Controller
{
    /**
     * POST /api/auth/register
     * User baru mendaftar akun
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        // Hitung umur (age) secara otomatis dari tgl_lahir/date_of_birth
        $dob = new \DateTime($request->date_of_birth ?? $request->tgl_lahir);
        $now = new \DateTime();
        $age = $now->diff($dob)->y;

        $user = User::create([
            'name'            => $request->name,
            'email'           => $request->email,
            'password'        => Hash::make($request->password),
            'gender'          => $request->gender,
            'tgl_lahir'       => $dob->format('Y-m-d H:i:s'), // Simpan ke tgl_lahir
            'age'             => $age,                        // Simpan ke age
            'region'          => $request->region,
            'education_level' => $request->education_level,
            'daily_role'      => $request->daily_role,
            'income_level'    => $request->income_level,
        ]);

        $token = JWTAuth::fromUser($user);

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil',
            'data'    => [
                'user'  => $user,
                'token' => $token,
            ],
        ], 201);
    }

    /**
     * POST /api/auth/login
     * Login dan dapat JWT token
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $credentials = $request->only('email', 'password');

        try {
            if (! $token = JWTAuth::attempt($credentials)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Email atau password salah',
                ], 401);
            }
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat token',
            ], 500);
        }

        // Update last_login
        $user = auth()->user();
        $user->update(['last_login' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data'    => [
                'token'      => $token,
                'token_type' => 'bearer',
                'expires_in' => config('jwt.ttl') * 60,
                'user'       => $user,
            ],
        ]);
    }

    /**
     * POST /api/auth/logout
     * Invalidate JWT token
     */
    public function logout(): JsonResponse
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal logout',
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil',
        ]);
    }

    /**
     * GET /api/auth/me
     * Ambil data user yang sedang login
     */
    public function me(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data'    => auth()->user(),
        ]);
    }

    /**
     * POST /api/auth/refresh
     * Refresh JWT token
     */
    public function refresh(): JsonResponse
    {
        try {
            $newToken = JWTAuth::refresh(JWTAuth::getToken());
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token tidak valid atau sudah expired',
            ], 401);
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'token'      => $newToken,
                'token_type' => 'bearer',
                'expires_in' => config('jwt.ttl') * 60,
            ],
        ]);
    }

    /**
     * PUT /api/auth/profile
     * Update profil user
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $request->validate([
            'name'            => 'sometimes|string|max:255',
            'gender'          => 'sometimes|in:Male,Female',
            'date_of_birth'   => 'sometimes|date|before:today',
            'region'          => 'sometimes|string|max:100',
            'education_level' => 'sometimes|string|max:100',
            'daily_role'      => 'sometimes|string|max:100',
            'income_level'    => 'sometimes|string|max:100',
        ]);

        /** @var \App\Models\User $user */
        $user = auth()->user();

        $user->update(
            $request->only([
                'name',
                'gender',
                'date_of_birth',
                'region',
                'education_level',
                'daily_role',
                'income_level',
            ])
        );

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui',
            'data'    => $user->fresh(),
        ]);
    }

    /**
     * POST /api/auth/change-password
     * User ubah password dengan memasukkan password lama terlebih dahulu
     * Protected: Perlu JWT token
     */
    public function changePassword(Request $request): JsonResponse
    {
        $request->validate([
            'current_password'      => 'required|string|min:8',
            'password'              => 'required|string|min:8|confirmed',
            'password_confirmation' => 'required',
        ]);

        /** @var \App\Models\User $user */
        $user = auth()->user();

        // Validasi password lama
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password lama tidak sesuai',
            ], 401);
        }

        // Validasi password baru tidak sama dengan password lama
        if (Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password baru tidak boleh sama dengan password lama',
            ], 422);
        }

        try {
            $user->update(['password' => Hash::make($request->password)]);

            return response()->json([
                'success' => true,
                'message' => 'Password berhasil diubah',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengubah password: ' . $e->getMessage(),
            ], 500);
        }
    }
}