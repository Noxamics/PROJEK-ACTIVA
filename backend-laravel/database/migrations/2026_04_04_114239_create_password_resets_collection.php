<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Collection: password_resets
 *
 * Fields:
 *   _id, email, otp_code, expired_at, verified
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->create('password_resets', function (Blueprint $collection) {
            $collection->string('email')->index();
            $collection->string('otp_code');
            $collection->timestamp('expired_at');
            $collection->boolean('verified')->default(false);
        });
    }

    public function down(): void
    {
        Schema::connection('mongodb')->dropIfExists('password_resets');
    }
};
