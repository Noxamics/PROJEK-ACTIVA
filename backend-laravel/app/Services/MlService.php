<?php

namespace App\Services;

use App\Models\MlResult;
use App\Models\Questionnaire;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MlService
{
    private string $baseUrl;
    private int $timeout;

    public function __construct(private AiAnalysisService $aiService)
    {
        $this->baseUrl = config('services.ml.url', 'http://localhost:5000');
        $this->timeout = config('services.ml.timeout', 30);
    }

    /**
     * @return array{success: bool, data?: MlResult, error?: string}
     */
    public function predict(Questionnaire $questionnaire): array
    {
        $payload = $this->buildPayload($questionnaire);

        try {
            $response = Http::timeout($this->timeout)
                ->withHeaders(['Accept' => 'application/json'])
                ->post("{$this->baseUrl}/predict", $payload);

            if (!$response->successful()) {
                Log::error('ML Service error', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                    'survey' => $questionnaire->_id,
                ]);
                return [
                    'success' => false,
                    'error' => "Flask mengembalikan HTTP {$response->status()}",
                ];
            }

            $mlData = $response->json();

            if (!$this->isValidResponse($mlData)) {
                return [
                    'success' => false,
                    'error' => 'Response Flask tidak sesuai format yang diharapkan',
                ];
            }

            // Generate AI analysis via Groq (atau driver lain)
            $aiResult = $this->generateAiAnalysis(
                score: $mlData['digital_dependence_score'],
                category: $mlData['category'],
                penyebab: $mlData['penyebab'],
                rawInput: $mlData['raw_input'],
            );

            // Simpan ke MongoDB
            $mlResult = $this->saveMlResult($questionnaire, $mlData, $aiResult);

            return [
                'success' => true,
                'data' => $mlResult,
            ];

        } catch (\Illuminate\Http\Client\ConnectionException $e) {
            Log::error('ML Service unreachable', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => 'Flask ML service tidak bisa dihubungi',
            ];
        } catch (\Exception $e) {
            Log::error('ML Service unexpected error', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => 'Terjadi kesalahan tak terduga',
            ];
        }
    }

    // ─── Private Helpers ────────────────────────────────────────────────────

    private function buildPayload(Questionnaire $questionnaire): array
    {
        $user = User::find($questionnaire->user_id);

        return [
            'questionnaire_id' => (string) $questionnaire->_id,
            'gender' => $user->gender ?? 'Male',
            'date_of_birth' => ($user->date_of_birth ?? $user->tgl_lahir) ? \Carbon\Carbon::parse(($user->date_of_birth ?? $user->tgl_lahir))->format('Y-m-d') : null,
            'age' => $user->age ?? 20,
            'region' => $user->region ?? 'Asia',
            'education_level' => $user->education_level ?? 'High School',
            'daily_role' => $user->daily_role ?? 'Student',
            'income_level' => $user->income_level ?? 'Low',
            'device_type' => $questionnaire->device_type ?? 'Android',
            'device_hours_per_day' => $questionnaire->device_hours_per_day,
            'phone_unlocks' => $questionnaire->phone_unlocks,
            'notifications_per_day' => $questionnaire->notifications_per_day,
            'social_media_mins' => $questionnaire->social_media_mins,
            'study_minutes' => $questionnaire->study_minutes,
            'physical_activity_days' => $questionnaire->physical_activity_days,
            'sleep_hours' => $questionnaire->sleep_hours,
            'sleep_quality' => $questionnaire->sleep_quality,
            'anxiety_score' => $questionnaire->anxiety_score,
            'depression_score' => $questionnaire->depression_score,
            'stress_level' => $questionnaire->stress_level,
            'happiness_score' => $questionnaire->happiness_score,
        ];
    }

    private function isValidResponse(array $data): bool
    {
        $required = [
            'digital_dependence_score',
            'category',
            'confidence',
            'penyebab',
            'raw_input',
        ];

        foreach ($required as $field) {
            if (!array_key_exists($field, $data)) {
                Log::warning("ML response missing field: {$field}");
                return false;
            }
        }

        return true;
    }

    private function generateAiAnalysis(
        float $score,
        string $category,
        array $penyebab,
        array $rawInput,
    ): array {
        try {
            return $this->aiService->generate(
                score: $score,
                category: $category,
                penyebab: $penyebab,
                rawInput: $rawInput,
            );
        } catch (\RuntimeException $e) {
            // AI gagal → ML result tetap disimpan, ai_analysis kosong
            Log::warning('AI analysis gagal, lanjut tanpa AI', [
                'error' => $e->getMessage(),
            ]);

            return [
                'penyebab' => $penyebab,
                'pembukaan' => '',
                'rekomendasi' => array_map(fn($tag) => [
                    'tag' => $tag,
                    'isi' => '',
                ], $penyebab),
            ];
        }
    }

    private function saveMlResult(
        Questionnaire $questionnaire,
        array $mlData,
        array $aiResult,
    ): MlResult {
        $weekGroup = now()->format('Y') . '-W' . str_pad(now()->isoWeek(), 2, '0', STR_PAD_LEFT);

        return MlResult::updateOrCreate(
            ['questionnaire_id' => $questionnaire->_id],
            [
                'user_id' => $questionnaire->user_id,
                'ml_result' => [
                    'digital_dependence_score' => $mlData['digital_dependence_score'],
                    'category' => $mlData['category'],
                    'confidence' => $mlData['confidence'],
                    'high_risk_flag' => $mlData['high_risk_flag'] ?? 0,
                ],
                'ai_analysis' => [
                    'penyebab' => $aiResult['penyebab'],
                    'pembukaan' => $aiResult['pembukaan'],
                    'rekomendasi' => $aiResult['rekomendasi'],
                    'generated_at' => now()->toISOString(),
                ],
                'week_group' => $weekGroup,
            ]
        );
    }
}