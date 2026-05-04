<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * FILE: database/seeders/RecommendationRulesSeeder.php
 *
 * Isi data awal recommendation_rules di MongoDB.
 * Jalankan: php artisan db:seed --class=RecommendationRulesSeeder
 *
 * ⚠️  Seeder ini truncate collection lebih dulu, aman dijalankan ulang.
 */
class RecommendationRulesSeeder extends Seeder
{
    public function run(): void
    {
        DB::connection('mongodb')->collection('recommendation_rules')->truncate();

        $now   = now();
        $rules = [
            // ── Sleep ─────────────────────────────────────────────────────────
            [
                'rule_id'             => 'rule_001',
                'condition_field'     => 'sleep_hours',
                'condition_operator'  => '<',
                'condition_value'     => 6.0,
                'recommendation_text' => 'Tingkatkan jam tidur minimal 7 jam per malam.',
                'category'            => 'sleep',
                'priority'            => 1,
                'is_active'           => true,
            ],
            [
                'rule_id'             => 'rule_002',
                'condition_field'     => 'sleep_quality',
                'condition_operator'  => '<',
                'condition_value'     => 5.0,
                'recommendation_text' => 'Hindari layar gadget minimal 1 jam sebelum tidur untuk meningkatkan kualitas tidur.',
                'category'            => 'sleep',
                'priority'            => 2,
                'is_active'           => true,
            ],

            // ── Social Media ──────────────────────────────────────────────────
            [
                'rule_id'             => 'rule_003',
                'condition_field'     => 'social_media_minutes',
                'condition_operator'  => '>',
                'condition_value'     => 180.0,
                'recommendation_text' => 'Kurangi penggunaan media sosial, targetkan maksimal 90 menit per hari.',
                'category'            => 'social_media',
                'priority'            => 1,
                'is_active'           => true,
            ],

            // ── Device Usage ──────────────────────────────────────────────────
            [
                'rule_id'             => 'rule_004',
                'condition_field'     => 'device_hours_per_day',
                'condition_operator'  => '>',
                'condition_value'     => 8.0,
                'recommendation_text' => 'Batasi penggunaan perangkat digital, idealnya tidak lebih dari 6 jam per hari.',
                'category'            => 'device',
                'priority'            => 1,
                'is_active'           => true,
            ],
            [
                'rule_id'             => 'rule_005',
                'condition_field'     => 'phone_unlocks_per_day',
                'condition_operator'  => '>',
                'condition_value'     => 80.0,
                'recommendation_text' => 'Kurangi kebiasaan membuka HP tanpa tujuan, aktifkan fitur Focus/Do Not Disturb.',
                'category'            => 'device',
                'priority'            => 2,
                'is_active'           => true,
            ],

            // ── Physical Activity ─────────────────────────────────────────────
            [
                'rule_id'             => 'rule_006',
                'condition_field'     => 'physical_activity_days',
                'condition_operator'  => '<',
                'condition_value'     => 3.0,
                'recommendation_text' => 'Lakukan aktivitas fisik minimal 3 hari per minggu, cukup 30 menit per sesi.',
                'category'            => 'exercise',
                'priority'            => 1,
                'is_active'           => true,
            ],

            // ── Mental Health ─────────────────────────────────────────────────
            [
                'rule_id'             => 'rule_007',
                'condition_field'     => 'anxiety_score',
                'condition_operator'  => '>',
                'condition_value'     => 7.0,
                'recommendation_text' => 'Coba teknik pernapasan dalam atau meditasi 10 menit setiap hari untuk mengurangi kecemasan.',
                'category'            => 'mental_health',
                'priority'            => 1,
                'is_active'           => true,
            ],
            [
                'rule_id'             => 'rule_008',
                'condition_field'     => 'stress_level',
                'condition_operator'  => '>',
                'condition_value'     => 7.0,
                'recommendation_text' => 'Buat jadwal harian yang terstruktur dan ambil istirahat pendek setiap 90 menit.',
                'category'            => 'mental_health',
                'priority'            => 2,
                'is_active'           => true,
            ],
            [
                'rule_id'             => 'rule_009',
                'condition_field'     => 'depression_score',
                'condition_operator'  => '>',
                'condition_value'     => 6.0,
                'recommendation_text' => 'Pertimbangkan untuk berkonsultasi dengan psikolog atau konselor jika perasaan ini berlanjut.',
                'category'            => 'mental_health',
                'priority'            => 1,
                'is_active'           => true,
            ],

            // ── Study / Productivity ──────────────────────────────────────────
            [
                'rule_id'             => 'rule_010',
                'condition_field'     => 'study_minutes',
                'condition_operator'  => '<',
                'condition_value'     => 60.0,
                'recommendation_text' => 'Usahakan sesi belajar minimal 60–90 menit per hari tanpa gangguan notifikasi.',
                'category'            => 'productivity',
                'priority'            => 2,
                'is_active'           => true,
            ],
        ];

        $rules = array_map(fn ($r) => array_merge($r, [
            'created_by' => null,
            'created_at' => $now,
            'updated_at' => $now,
        ]), $rules);

        DB::connection('mongodb')->collection('recommendation_rules')->insert($rules);

        $this->command->info('✓ ' . count($rules) . ' recommendation rules berhasil di-seed ke MongoDB.');
    }
}
