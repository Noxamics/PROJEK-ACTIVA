<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PrediksiController;
use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\PasswordResetController;
use App\Http\Controllers\PredictController; 
use App\Http\Controllers\SurveyController;
use Illuminate\Support\Facades\Route;

/*
|══════════════════════════════════════════════════════════════
| routes/api.php  —  LENGKAP (Member 1 — Backend Lead)
|══════════════════════════════════════════════════════════════
|
| PUBLIC (tanpa JWT)
| ├── POST  /api/auth/register
| ├── POST  /api/auth/login
| ├── POST  /api/auth/forgot-password
| ├── POST  /api/auth/verify-otp
| ├── POST  /api/auth/reset-password
| └── POST  /api/admin/login
|
| USER PROTECTED (JWT user biasa)
| Auth ──────────────────────────────────────────────────────
| ├── GET   /api/auth/me
| ├── POST  /api/auth/logout
| ├── POST  /api/auth/refresh
| ├── PUT   /api/auth/profile
| ├── POST  /api/auth/change-password
| ├── POST  /api/auth/forgot-password (public)
| ├── POST  /api/auth/verify-otp (public)
| └── POST  /api/auth/reset-password (public)
|
| Survey ─────────────────────────────────────────────────────
| ├── GET   /api/surveys
| ├── POST  /api/surveys        <- trigger ML otomatis
| ├── GET   /api/surveys/latest
| ├── GET   /api/surveys/{id}
| └── DELETE /api/surveys/{id}
|
| Prediksi ───────────────────────────────────────────────────
| ├── GET   /api/prediksi
| ├── GET   /api/prediksi/latest
| ├── GET   /api/prediksi/summary
| ├── GET   /api/prediksi/{id}
| └── POST  /api/prediksi/retry/{questionnaireId}
|
| Analytics ──────────────────────────────────────────────────
| ├── GET   /api/analytics/insight
| ├── GET   /api/analytics/comparison
| └── GET   /api/analytics/history?days=30
|
| ADMIN PROTECTED (JWT admin)
| ├── GET   /api/admin/dashboard
| ├── GET   /api/admin/users
| ├── GET   /api/admin/users/{id}
| └── GET   /api/admin/report/export
|══════════════════════════════════════════════════════════════
*/
// PUBLIC
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('forgot-password', [PasswordResetController::class, 'forgotPassword']);
    Route::post('verify-otp', [PasswordResetController::class, 'verifyOtp']);
    Route::post('reset-password', [PasswordResetController::class, 'resetPassword']);
    Route::get('/surveys', [SurveyController::class, 'index']);
});

// Admin Public Endpoints (OTP & Login)
Route::post('admin/login', [AdminController::class, 'login']);
Route::post('admin/request-otp', [AdminController::class, 'requestOtp']);
Route::post('admin/verify-otp', [AdminController::class, 'verifyOtp']);

// USER PROTECTED
Route::middleware('jwt.auth')->group(function () {

    Route::prefix('auth')->group(function () {
        Route::get('me', [AuthController::class, 'me']);
        Route::post('logout', [AuthController::class, 'logout']);
        Route::post('refresh', [AuthController::class, 'refresh']);
        Route::put('profile', [AuthController::class, 'updateProfile']);
        Route::post('change-password', [AuthController::class, 'changePassword']);
    });

    Route::prefix('surveys')->group(function () {
        Route::get('/', [SurveyController::class, 'index']);
        Route::post('/', [SurveyController::class, 'store']);
        Route::get('latest', [SurveyController::class, 'latest']);
        Route::get('{id}', [SurveyController::class, 'show']);
        Route::delete('{id}', [SurveyController::class, 'destroy']);
    });

    Route::prefix('analytics')->group(function () {
        Route::get('insight', [AnalyticsController::class, 'insight']);
        Route::get('comparison', [AnalyticsController::class, 'comparison']);
        Route::get('history', [AnalyticsController::class, 'history']);
    });

});

// ADMIN PROTECTED
Route::middleware('jwt.admin')->prefix('admin-panel')->group(function () {
    Route::get('dashboard', [AdminController::class, 'dashboard']);
    Route::get('users', [AdminController::class, 'users']);
    Route::get('users/{id}', [AdminController::class, 'userDetail']);
    Route::get('report/export', [AdminController::class, 'exportReport']);
});

// FALLBACK
Route::fallback(fn() => response()->json([
    'success' => false,
    'message' => 'Endpoint tidak ditemukan',
], 404));