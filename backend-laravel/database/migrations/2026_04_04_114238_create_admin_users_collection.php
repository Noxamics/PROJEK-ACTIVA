<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Collection: admin_users
 *
 * Fields:
 *   _id, name, email, role, is_active, created_at
 *
 * Catatan:
 *   - Tidak ada 'password' — admin login via email + OTP (nilai OTP dari ENV)
 *   - Tidak ada 'updated_at' — tidak diperlukan
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->create('admin_users', function (Blueprint $collection) {
            $collection->string('name');
            $collection->string('email')->unique();
            $collection->string('role')->default('admin');
            $collection->boolean('is_active')->default(true);
            $collection->timestamp('created_at')->nullable();
        });
    }

    public function down(): void
    {
        Schema::connection('mongodb')->dropIfExists('admin_users');
    }
};
