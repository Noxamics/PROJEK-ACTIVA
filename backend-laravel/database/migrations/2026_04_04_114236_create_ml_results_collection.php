<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Collection: ml_results
 *
 * Fields:
 *   _id, user_id, questionnaire_id,
 *
 *   ml_result: {                          ← embedded object
 *     digital_dependence_score: float,
 *     category: string,                   // "rendah" | "sedang" | "tinggi"
 *     confidence: float
 *   },
 *
 *   ai_analysis: {                        ← embedded object
 *     penyebab: [ "tidur_kurang", "screen_time_tinggi" ],
 *     rekomendasi: [
 *       { tag: "sleep", isi: "Coba tidur lebih awal..." },
 *       { tag: "social_media", isi: "Kurangi penggunaan..." }
 *     ],
 *     summary: string,
 *     model: "gemini-pro",
 *     generated_at: ISODate
 *   },
 *
 *   week_group: "2026-W17",
 *   created_at
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->create('ml_results', function (Blueprint $collection) {
            $collection->string('user_id')->index();
            $collection->string('questionnaire_id')->index();

            // Embedded object: ml_result
            // Disimpan langsung di MongoDB sebagai sub-document
            // { digital_dependence_score: float, category: string, confidence: float }

            // Embedded object: ai_analysis
            // { penyebab: array, rekomendasi: array, summary: string, model: string, generated_at: datetime }

            $collection->string('week_group')->index(); // "2026-W17"
            $collection->timestamp('created_at')->nullable();
        });
    }

    public function down(): void
    {
        Schema::connection('mongodb')->dropIfExists('ml_results');
    }
};
