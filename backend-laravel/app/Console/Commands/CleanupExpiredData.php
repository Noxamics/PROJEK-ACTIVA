<?php

namespace App\Console\Commands;

use App\Models\PasswordReset;
use App\Models\AnalyticsLog;
use Illuminate\Console\Command;

/**
 * FILE: app/Console/Commands/CleanupExpiredData.php
 *
 * Daftarkan di app/Console/Kernel.php:
 *   $schedule->command('app:cleanup')->daily();
 *
 * Atau jalankan manual:
 *   php artisan app:cleanup
 */
class CleanupExpiredData extends Command
{
    protected $signature   = 'app:cleanup';
    protected $description = 'Hapus OTP expired dan analytics log lama (>90 hari)';

    public function handle(): int
    {
        // 1. Hapus OTP yang sudah expired
        $otpDeleted = PasswordReset::where('expired_at', '<', now())->delete();
        $this->info("OTP expired dihapus: {$otpDeleted} record");

        // 2. Hapus analytics log lebih dari 90 hari (hemat storage MongoDB)
        $logsDeleted = AnalyticsLog::where('created_at', '<', now()->subDays(90))->delete();
        $this->info("Analytics log lama dihapus: {$logsDeleted} record");

        $this->info('Cleanup selesai.');
        return Command::SUCCESS;
    }
}