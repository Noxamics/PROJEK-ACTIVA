<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Collection: recommendation_rules
 *
 * Digunakan sebagai fallback kalau tidak pakai AI.
 *
 * Fields:
 *   _id, name,
 *   conditions: {                         ← embedded object
 *     category: "tinggi",
 *     social_media_minutes: { min: 180 },
 *     sleep_hours: { max: 6 }
 *   },
 *   recommendation: string,
 *   priority: int (1 = tertinggi),
 *   is_active: boolean,
 *   created_at, updated_at
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->create('recommendation_rules', function (Blueprint $collection) {
            $collection->string('name');

            // Embedded object: conditions
            // Disimpan langsung di MongoDB sebagai sub-document
            // { category: string, social_media_minutes: { min: int }, sleep_hours: { max: int }, ... }

            $collection->string('recommendation');
            $collection->integer('priority')->default(1)->index();
            $collection->boolean('is_active')->default(true)->index();

            $collection->timestamps(); // created_at & updated_at
        });
    }

    public function down(): void
    {
        Schema::connection('mongodb')->dropIfExists('recommendation_rules');
    }
};
