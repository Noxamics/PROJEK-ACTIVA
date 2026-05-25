<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\PasswordResetController;
use App\Http\Controllers\SurveyController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\LaporanController;
use App\Http\Controllers\Api\ExportController;

// ── PUBLIC ────────────────────────────────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('forgot-password', [PasswordResetController::class, 'forgotPassword']);
    Route::post('verify-otp', [PasswordResetController::class, 'verifyOtp']);
    Route::post('reset-password', [PasswordResetController::class, 'resetPassword']);
    // HAPUS: Route::get('/surveys', ...) yang ada di sini sebelumnya
});

Route::post('admin/login', [AdminController::class, 'login']);
Route::post('admin/request-otp', [AdminController::class, 'requestOtp']);
Route::post('admin/verify-otp', [AdminController::class, 'verifyOtp']);

// ── USER PROTECTED ────────────────────────────────────────────────────────
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

    Route::get('/laporan', [LaporanController::class, 'getLaporan']);
    Route::get('/export', [ExportController::class, 'export']);
});

// ── ADMIN PROTECTED ───────────────────────────────────────────────────────
Route::middleware('jwt.admin')->prefix('admin-panel')->group(function () {
    Route::get('dashboard', [AdminController::class, 'dashboard']);
    Route::get('users', [AdminController::class, 'users']);
    Route::get('users/{id}', [AdminController::class, 'userDetail']);
    Route::get('report/export', [AdminController::class, 'exportReport']);
});

// ── FALLBACK ──────────────────────────────────────────────────────────────
Route::fallback(fn() => response()->json([
    'success' => false,
    'message' => 'Endpoint tidak ditemukan',
], 404));