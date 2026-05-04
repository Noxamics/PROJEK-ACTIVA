<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Collection: users
 *
 * Fields:
 *   _id, name, email, password_hash,
 *   gender, tgl_lahir, age, region,    
 *   education_level, daily_role, income_level,
 *   created_at, last_login
 */
return new class extends Migration {
    public function up(): void
    {
        Schema::connection('mongodb')->create('users', function (Blueprint $collection) {
            $collection->string('name');
            $collection->string('email')->unique();
            $collection->string('password_hash');

            $collection->string('gender')->nullable();
            $collection->dateTime('tgl_lahir')->nullable();
            $collection->integer('age')->nullable(); // Dihasilkan dari tgl_lahir
            $collection->string('region')->nullable();
            $collection->string('education_level')->nullable();
            $collection->string('daily_role')->nullable();       // e.g. "Student"
            $collection->string('income_level')->nullable();     // e.g. "High"

            $collection->timestamp('last_login')->nullable();
            $collection->timestamps(); // created_at & updated_at
        });
    }

    public function down(): void
    {
        Schema::connection('mongodb')->dropIfExists('users');
    }
};
