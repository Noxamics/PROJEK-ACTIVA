<?php

namespace Database\Seeders;

use App\Models\Admin;        // ← ganti dari AdminUser
use App\Models\MlResult;
use App\Models\Questionnaire;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ── 1. Recommendation Rules ───────────────────────────────────────
        $this->call(RecommendationRulesSeeder::class);

        // ── 2. Admin default dari ENV ─────────────────────────────────────
        // Login via OTP — tidak ada password
        Admin::updateOrCreate(
            ['email' => strtolower(trim(env('ADMIN_EMAIL', 'admin@app.local')))],
            [
                'full_name' => env('ADMIN_NAME', 'Administrator'),
                'email' => strtolower(trim(env('ADMIN_EMAIL', 'admin@app.local'))),
                'is_active' => true,
            ]
        );

        $this->command->info('✓ Admin berhasil dibuat:');
        $this->command->info('  Email : ' . env('ADMIN_EMAIL', 'admin@app.local'));
        $this->command->info('  Login : via OTP ke email tersebut');

        // ── 3. Demo user ──────────────────────────────────────────────────
        $demo = User::updateOrCreate(
            ['email' => 'demo@digitalliving.app'],
            [
                'name' => 'Demo User',
                'email' => 'demo@digitalliving.app',
                'password_hash' => bcrypt('demo1234'),
                'gender' => 'male',
                'age' => 21,
                'region' => 'Jawa Timur',
                'education_level' => 'S1',
                'last_login' => null,
            ]
        );

        $this->command->info('✓ Demo user: demo@digitalliving.app / demo1234');

        // ── 4. Dummy surveys + ML results (7 hari) ────────────────────────
        $focusValues = [55, 60, 58, 72, 68, 75, 70];

        foreach ($focusValues as $i => $focus) {
            $q = Questionnaire::create([
                'user_id' => (string) $demo->_id,
                'income_level' => 'menengah',
                'daily_role' => 'mahasiswa',
                'device_hours_per_day' => round(8.5 - ($i * 0.2), 1),
                'phone_unlocks_per_day' => 70 - ($i * 2),
                'notifications_per_day' => 120,
                'social_media_minutes' => 200 - ($i * 10),
                'study_minutes' => 90 + ($i * 15),
                'physical_activity_days' => 2 + ($i % 3),
                'sleep_hours' => 6.5,
                'sleep_quality' => 6,
                'anxiety_score' => 5,
                'depression_score' => 4,
                'stress_level' => 5,
                'happiness_score' => round(6 + ($i * 0.2), 1),
                'created_at' => now()->subDays(6 - $i),
            ]);

            MlResult::create([
                'user_id' => (string) $demo->_id,
                'questionnaire_id' => (string) $q->_id,
                'focus_score' => $focus,
                'productivity_score' => $focus - 5 + rand(-3, 3),
                'digital_dependence_score' => 80 - $focus,
                'high_risk_flag' => $focus < 60,
                'recommendations' => [
                    'Kurangi penggunaan media sosial',
                    'Tidur minimal 7 jam per hari',
                    'Olahraga minimal 3x seminggu',
                ],
                'created_at' => now()->subDays(6 - $i),
                'updated_at' => now()->subDays(6 - $i),
            ]);
        }

        $this->command->info('✓ 7 dummy surveys + ML results selesai di-seed.');
    }
}