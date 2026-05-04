<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\MlResult;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;

class AdminController extends Controller
{
    /**
     * POST /api/admin/login
     * Admin login dengan email & password
     */
    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        $admin = Admin::where('email', $validated['email'])->first();

        if (!$admin || !Hash::check($validated['password'], $admin->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah',
            ], 401);
        }

        $token = JWTAuth::fromUser($admin);

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data'    => [
                'admin' => $admin,
                'token' => $token,
            ],
        ]);
    }

    /**
     * POST /api/admin/request-otp
     * Admin request OTP untuk login
     */
    public function requestOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email',
        ]);

        $admin = Admin::where('email', $validated['email'])->first();

        if (!$admin) {
            return response()->json([
                'success' => false,
                'message' => 'Admin tidak ditemukan',
            ], 404);
        }

        // Generate OTP
        $otp = rand(100000, 999999);
        $admin->update(['otp_code' => $otp]);

        // TODO: Kirim OTP via email/SMS

        return response()->json([
            'success' => true,
            'message' => 'OTP telah dikirim',
        ]);
    }

    /**
     * POST /api/admin/verify-otp
     * Admin verify OTP
     */
    public function verifyOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email'    => 'required|email',
            'otp_code' => 'required|numeric',
        ]);

        $admin = Admin::where('email', $validated['email'])
                      ->where('otp_code', $validated['otp_code'])
                      ->first();

        if (!$admin) {
            return response()->json([
                'success' => false,
                'message' => 'OTP tidak valid atau sudah expired',
            ], 401);
        }

        $admin->update(['otp_code' => null]);
        $token = JWTAuth::fromUser($admin);

        return response()->json([
            'success' => true,
            'message' => 'Verifikasi berhasil',
            'data'    => [
                'admin' => $admin,
                'token' => $token,
            ],
        ]);
    }

    /**
     * GET /api/admin-panel/dashboard
     * Get admin dashboard stats
     */
    public function dashboard(): JsonResponse
    {
        $stats = [
            'total_users'    => User::count(),
            'active_today'   => User::whereDate('last_login', now()->today())->count(),
            'new_7days'      => User::where('created_at', '>=', now()->subDays(7))->count(),
            'high_risk_users' => MlResult::where('ml_result.category', 'tinggi')->distinct('user_id')->count(),
        ];

        return response()->json([
            'success' => true,
            'data'    => $stats,
        ]);
    }

    /**
     * GET /api/admin-panel/users
     * Get list of all users with pagination
     */
    public function users(Request $request): JsonResponse
    {
        $perPage = $request->query('per_page', 15);
        $users = User::paginate($perPage);

        return response()->json([
            'success' => true,
            'data'    => $users,
        ]);
    }

    /**
     * GET /api/admin-panel/users/{id}
     * Get detail of a specific user
     */
    public function userDetail($id): JsonResponse
    {
        $user = User::findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => $user,
        ]);
    }

    /**
     * GET /api/admin-panel/report/export
     * Export admin report (CSV/Excel)
     */
    public function exportReport(Request $request): JsonResponse
    {
        $format = $request->query('format', 'json');
        
        $users = User::select('name', 'email', 'gender', 'region', 'education_level', 'created_at')->get();

        if ($format === 'csv') {
            // TODO: Generate CSV file
            return response()->json([
                'success' => true,
                'message' => 'Export CSV dimulai',
            ]);
        }

        return response()->json([
            'success' => true,
            'data'    => $users,
        ]);
    }
}
