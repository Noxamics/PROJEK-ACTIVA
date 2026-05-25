<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AdminOtpController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\MonitoringController;
use App\Http\Controllers\Admin\KuesionerController;
use App\Http\Controllers\Admin\RuleController;
use App\Http\Controllers\Admin\ExportCenterController;
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

    // Export Center
    Route::get('/export', [ExportCenterController::class, 'index'])->name('admin.export');
    Route::get('/export/download', [ExportCenterController::class, 'download'])->name('admin.export.download');
});

// Predict routes
Route::middleware(['admin'])->prefix('admin')->group(function () {
    Route::post('/predict', [SurveyController::class, 'index'])->name('admin.predict');
});

// ════════════════════════════════════════════════════
// User Web Routes (Blade — same flow as mobile Flutter)
// ════════════════════════════════════════════════════
use App\Http\Controllers\Web\AuthController as WebAuth;
use App\Http\Controllers\Web\LandingController as WebLanding;
use App\Http\Controllers\Web\DashboardController as WebDashboard;
use App\Http\Controllers\Web\KuesionerController as WebKuesioner;
use App\Http\Controllers\Web\HasilController as WebHasil;
use App\Http\Controllers\Web\HistoriController as WebHistori;
use App\Http\Controllers\Web\GrafikController as WebGrafik;
use App\Http\Controllers\Web\LaporanController as WebLaporan;
use App\Http\Controllers\Web\ProfilController as WebProfil;

Route::prefix('user')->group(function () {
    // Landing page (public)
    Route::get('/landing', [WebLanding::class, 'index'])->name('user.landing');

    // Auth (public)
    Route::get('/login', [WebAuth::class, 'showLogin'])->name('user.login');
    Route::post('/login', [WebAuth::class, 'login'])->name('user.login.post');
    Route::get('/register', [WebAuth::class, 'showRegister'])->name('user.register');
    Route::post('/register', [WebAuth::class, 'register'])->name('user.register.post');
    Route::post('/register/google-verify', [WebAuth::class, 'verifyGoogleToken'])->name('user.register.google-verify');
    Route::post('/logout', [WebAuth::class, 'logout'])->name('user.logout');

    // Forgot Password Flow (public)
    Route::get('/forgot', [WebAuth::class, 'showForgotPassword'])->name('user.forgot');
    Route::post('/forgot', [WebAuth::class, 'sendForgotOtp'])->name('user.forgot.post');
    Route::get('/otp-verify', [WebAuth::class, 'showOtpVerify'])->name('user.otp-verify');
    Route::post('/otp-verify', [WebAuth::class, 'verifyOtp'])->name('user.otp-verify.post');
    Route::post('/forgot-resend', [WebAuth::class, 'resendOtp'])->name('user.forgot-resend');
    Route::get('/reset-password', [WebAuth::class, 'showResetPassword'])->name('user.reset-password');
    Route::post('/reset-password', [WebAuth::class, 'resetPassword'])->name('user.reset-password.post');

    // Protected (session auth)
    Route::middleware('web.user')->group(function () {
        Route::get('/dashboard', [WebDashboard::class, 'index'])->name('user.dashboard');
        Route::get('/kuesioner', [WebKuesioner::class, 'index'])->name('user.kuesioner');
        Route::post('/kuesioner', [WebKuesioner::class, 'store'])->name('user.kuesioner.store');
        Route::get('/hasil/{id}', [WebHasil::class, 'show'])->name('user.hasil');
        Route::get('/histori', [WebHistori::class, 'index'])->name('user.histori');
        Route::get('/grafik', [WebGrafik::class, 'index'])->name('user.grafik');
        Route::get('/laporan', [WebLaporan::class, 'index'])->name('user.laporan');
        Route::get('/profil', [WebProfil::class, 'index'])->name('user.profil');
        Route::put('/profil', [WebProfil::class, 'update'])->name('user.profil.update');
        Route::post('/profil/password', [WebProfil::class, 'changePassword'])->name('user.profil.password');
    });
});