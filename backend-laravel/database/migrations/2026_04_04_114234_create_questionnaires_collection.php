<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Collection: questionnaires
 *
 * Fields:
 *   _id, user_id,
 *   device_hours_per_day, phone_unlocks_per_day, notifications_per_day,
 *   social_media_minutes, study_minutes, physical_activity_days,
 *   sleep_hours, sleep_quality,
 *   anxiety_score, depression_score, stress_level, happiness_score,
 *   device_type,
 *   created_at
 *
 * Catatan: tidak ada updated_at (kuesioner bersifat immutable setelah submit)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->create('questionnaires', function (Blueprint $collection) {
            $collection->string('user_id')->index();        // ObjectId user (simpan sebagai string)

            $collection->float('device_hours_per_day')->nullable();
            $collection->integer('phone_unlocks_per_day')->nullable();
            $collection->integer('notifications_per_day')->nullable();

            $collection->integer('social_media_minutes')->nullable();
            $collection->integer('study_minutes')->nullable();
            $collection->integer('physical_activity_days')->nullable();

            $collection->float('sleep_hours')->nullable();
            $collection->float('sleep_quality')->nullable();

            $collection->float('anxiety_score')->nullable();
            $collection->float('depression_score')->nullable();
            $collection->float('stress_level')->nullable();
            $collection->float('happiness_score')->nullable();

            // device_type: otomatis terisi "android" sebagai default,
            // atau bisa dipilih oleh user (android/ios)
            $collection->string('device_type')->default('android');

            $collection->timestamp('created_at')->nullable();
        });
    }

    public function down(): void
    {
        Schema::connection('mongodb')->dropIfExists('questionnaires');
    }
};
