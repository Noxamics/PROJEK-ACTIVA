<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AdminOtpController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\MonitoringController;
use App\Http\Controllers\Admin\KuesionerController;
use App\Http\Controllers\Admin\RuleController;
use App\Http\Controllers\SurveyController;

// ════════════════════════════════════════════════════
// Admin Authentication Routes (PUBLIC)
// ════════════════════════════════════════════════════
Route::get('/', [AdminOtpController::class, 'showLogin'])->name('login');
Route::post('/login', [AdminOtpController::class, 'sendOtp'])->name('admin.send-otp');
Route::post('/logout', [AdminOtpController::class, 'logout'])->name('admin.logout');
Route::get('/admin/verify-otp', [AdminOtpController::class, 'showVerify'])->name('admin.verify-otp');
Route::post('/admin/verify-otp', [AdminOtpController::class, 'verifyOtp'])->name('admin.verify-otp.process');

// ════════════════════════════════════════════════════
// Admin Protected Routes
// ════════════════════════════════════════════════════
// Ganti middleware 'auth.session' + 'admin.only' → pakai 'admin' saja
// (AdminMiddleware.php sudah handle keduanya sekaligus)
Route::middleware(['admin'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('admin.dashboard');
    Route::get('/users', [UserController::class, 'index'])->name('admin.users');
    Route::delete('/users/{id}', [UserController::class, 'destroy'])->name('admin.users.destroy');
    Route::get('/monitoring', [MonitoringController::class, 'index'])->name('admin.monitoring');
    Route::get('/kuesioner', [KuesionerController::class, 'index'])->name('admin.kuesioner');

    // Rules endpoints
    Route::get('/rules', [RuleController::class, 'index'])->name('admin.rules');
    Route::post('/rules', [RuleController::class, 'store'])->name('admin.rules.store');
    Route::patch('/rules/{id}/toggle', [RuleController::class, 'toggle'])->name('admin.rules.toggle');
    Route::delete('/rules/{id}', [RuleController::class, 'destroy'])->name('admin.rules.destroy');
});

// Predict routes
Route::middleware(['admin'])->prefix('admin')->group(function () {
    Route::post('/predict', [SurveyController::class, 'index'])->name('admin.predict');
});