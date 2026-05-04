<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Questionnaire;
use App\Services\MlService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tests\TestCase;

/**
 * ══════════════════════════════════════════════════════════════
 * FILE: tests/Feature/ApiTest.php
 * ══════════════════════════════════════════════════════════════
 * Unit test untuk endpoint Member 1 (Backend Lead)
 *
 * Jalankan: php artisan test --filter ApiTest
 * ══════════════════════════════════════════════════════════════
 */
class ApiTest extends TestCase
{
    use RefreshDatabase;

    // ─── Auth Tests ─────────────────────────────────────────

    public function test_user_can_register(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name'                  => 'Budi Santoso',
            'email'                 => 'budi@test.com',
            'password'              => 'password123',
            'password_confirmation' => 'password123',
            'age'                   => 21,
            'gender'                => 'male',
        ]);

        $response->assertStatus(201)
                 ->assertJsonStructure([
                     'success', 'message',
                     'data' => ['user', 'token'],
                 ])
                 ->assertJson(['success' => true]);
    }

    public function test_register_fails_with_duplicate_email(): void
    {
        User::factory()->create(['email' => 'duplikat@test.com']);

        $response = $this->postJson('/api/auth/register', [
            'name'                  => 'User Lain',
            'email'                 => 'duplikat@test.com',
            'password'              => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(422)
                 ->assertJson(['success' => false]);
    }

    public function test_user_can_login(): void
    {
        $user = User::factory()->create([
            'email'    => 'login@test.com',
            'password' => Hash::make('password123'),
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email'    => 'login@test.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'data' => ['token', 'token_type', 'expires_in', 'user'],
                 ]);
    }

    public function test_login_fails_with_wrong_password(): void
    {
        User::factory()->create([
            'email'    => 'salah@test.com',
            'password' => Hash::make('password123'),
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email'    => 'salah@test.com',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401);
    }

    public function test_protected_route_requires_token(): void
    {
        $this->getJson('/api/auth/me')->assertStatus(401);
    }

    public function test_user_can_get_own_profile(): void
    {
        $user  = User::factory()->create();
        $token = JWTAuth::fromUser($user);

        $response = $this->withToken($token)->getJson('/api/auth/me');

        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'data'    => ['email' => $user->email],
                 ]);
    }

    // ─── Survey Tests ────────────────────────────────────────

    public function test_user_can_submit_survey_and_get_prediction(): void
    {
        // Mock Flask ML service supaya test tidak butuh Flask running
        $this->mock(MlService::class, function ($mock) {
            $mock->shouldReceive('predict')->once()->andReturn([
                'success' => true,
                'data'    => [
                    'focus_score'               => 72.5,
                    'productivity_score'        => 68.0,
                    'digital_dependence_score'  => 55.0,
                    'high_risk_flag'            => false,
                    'recommendations'           => ['Kurangi waktu layar', 'Tidur lebih awal'],
                ],
            ]);
        });

        $user  = User::factory()->create();
        $token = JWTAuth::fromUser($user);

        $response = $this->withToken($token)->postJson('/api/surveys', [
            'device_hours_per_day'   => 8.5,
            'phone_unlocks_per_day'  => 60,
            'notifications_per_day'  => 120,
            'social_media_minutes'   => 180,
            'study_minutes'          => 120,
            'physical_activity_days' => 3,
            'sleep_hours'            => 6.5,
            'sleep_quality'          => 6,
            'anxiety_score'          => 5,
            'depression_score'       => 4,
            'stress_level'           => 6,
            'happiness_score'        => 6,
        ]);

        $response->assertStatus(201)
                 ->assertJsonStructure([
                     'data' => ['questionnaire', 'ml_result'],
                 ]);
    }

    public function test_survey_validation_rejects_invalid_data(): void
    {
        $user  = User::factory()->create();
        $token = JWTAuth::fromUser($user);

        // device_hours_per_day > 24 tidak valid
        $response = $this->withToken($token)->postJson('/api/surveys', [
            'device_hours_per_day' => 99, // invalid
        ]);

        $response->assertStatus(422)
                 ->assertJson(['success' => false]);
    }

    public function test_user_can_get_survey_list(): void
    {
        $user  = User::factory()->create();
        $token = JWTAuth::fromUser($user);

        Questionnaire::factory()->count(3)->create(['user_id' => $user->id]);

        $response = $this->withToken($token)->getJson('/api/surveys');

        $response->assertStatus(200)
                 ->assertJsonCount(3, 'data');
    }

    public function test_user_cannot_access_other_users_survey(): void
    {
        $user1  = User::factory()->create();
        $user2  = User::factory()->create();
        $token2 = JWTAuth::fromUser($user2);

        $survey = Questionnaire::factory()->create(['user_id' => $user1->id]);

        $response = $this->withToken($token2)->getJson("/api/surveys/{$survey->id}");

        $response->assertStatus(404); // bukan 403, biar tidak leak existence
    }

    // ─── Prediksi Tests ──────────────────────────────────────

    public function test_prediksi_summary_returns_correct_structure(): void
    {
        $user  = User::factory()->create();
        $token = JWTAuth::fromUser($user);

        $response = $this->withToken($token)->getJson('/api/prediksi/summary');

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'data' => [
                         'total_surveys', 'avg_focus_score',
                         'avg_productivity_score', 'avg_digital_dependence',
                         'high_risk_count', 'trend',
                     ],
                 ]);
    }
}
