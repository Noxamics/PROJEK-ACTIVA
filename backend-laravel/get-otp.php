<?php
require __DIR__ . '/vendor/autoload.php';
$app = require __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Carbon;

// Query OTP terbaru yang belum diverifikasi dan belum expired
$otp = DB::connection('mongodb')
    ->collection('admin_otps')
    ->where('verified', false)
    ->where('expired_at', '>', now()->timestamp * 1000) // Belum expired
    ->orderBy('created_at', 'desc')
    ->first();

if ($otp) {
    echo "═══════════════════════════════════════════\n";
    echo "✅ OTP CODE: " . $otp['otp_code'] . "\n";
    echo "═══════════════════════════════════════════\n";
    echo "Email: " . $otp['email'] . "\n";
    echo "Attempts: " . $otp['attempts'] . "/5\n";
    echo "Verified: " . ($otp['verified'] ? 'Yes' : 'No') . "\n";
    echo "═══════════════════════════════════════════\n";
} else {
    echo "❌ Tidak ada OTP yang valid (belum expired)\n\n";
    echo "Semua OTP terbaru:\n";
    $all_otps = DB::connection('mongodb')
        ->collection('admin_otps')
        ->orderBy('created_at', 'desc')
        ->limit(10)
        ->get();
    
    if ($all_otps->count() == 0) {
        echo "Tidak ada data OTP di database\n";
    } else {
        foreach ($all_otps as $item) {
            $verified = $item['verified'] ? 'Yes' : 'No';
            echo "OTP: " . $item['otp_code'] . " | Email: " . $item['email'] . " | Verified: " . $verified . "\n";
        }
    }
}
