<?php

namespace App\Services;

use App\Models\MlResult;
use App\Models\Questionnaire;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * MlService
 * ──────────────────────────────────────────────────────────
 * Bertanggung jawab mengirim data survey ke Flask REST-API
 * (ML / Data Science) dan menyimpan hasilnya ke MongoDB.
 *
 * Flow:
 *  Laravel  →  HTTP POST  →  Flask
 *           ←  JSON result ←
 *  Laravel simpan ke ml_results (embedded ml_result + ai_analysis)
 *
 * Expected Flask response:
 * {
 *   "digital_dependence_score": 60,
 *   "category": "sedang",
 *   "confidence": 0.82,
 *   "ai_analysis": {
 *     "penyebab": ["tidur_kurang", "screen_time_tinggi"],
 *     "rekomendasi": [
 *       { "tag": "sleep", "isi": "Coba tidur lebih awal..." },
 *       { "tag": "social_media", "isi": "Kurangi media sosial..." }
 *     ],
 *     "summary": "Ketergantungan dipengaruhi oleh...",
 *     "model": "gemini-pro"
 *   }
 * }
 */
class MlService
{
    private string $baseUrl;
    private int $timeout;

    public function __construct()
    {
        // URL Flask didapat dari .env: ML_SERVICE_URL=http://localhost:5000
        $this->baseUrl = config('services.ml.url', 'http://localhost:5000');
        $this->timeout = config('services.ml.timeout', 30);
    }

    /**
     * Kirim data questionnaire ke Flask dan simpan hasilnya.
     *
     * @return array{success: bool, data?: MlResult, error?: string}
     */
    public function predict(Questionnaire $questionnaire, ?User $user = null): array
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

            // Validasi response dari Flask
            if (!$this->isValidResponse($mlData)) {
                return [
                    'success' => false,
                    'error' => 'Response Flask tidak sesuai format yang diharapkan',
                ];
            }

            // Simpan ke MongoDB
            $mlResult = $this->saveMlResult($questionnaire, $mlData);

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

    /**
     * Buat payload JSON yang akan dikirim ke Flask.
     * Termasuk data user (dari register) + data questionnaire.
     */
    private function buildPayload(Questionnaire $questionnaire): array
    {
        // Ambil data user untuk field yang dipindah ke register
        $user = User::find($questionnaire->user_id);

        return [
            // Identifikasi
            'questionnaire_id' => (string) $questionnaire->_id,

            // Data dari User (register)
            'gender' => $user->gender ?? 'Male',
            'date_of_birth' => $user->date_of_birth?->format('Y-m-d'),
            'age' => $user->age ?? 20,
            'region' => $user->region ?? 'Asia',
            'education_level' => $user->education_level ?? 'High School',
            'daily_role' => $user->daily_role ?? 'Student',
            'income_level' => $user->income_level ?? 'Low',

            // Data dari Questionnaire
            'device_type' => $questionnaire->device_type ?? 'Android',
            'device_hours_per_day' => $questionnaire->device_hours_per_day,
            'phone_unlocks'          => $questionnaire->phone_unlocks,
            'notifications_per_day' => $questionnaire->notifications_per_day,
            'social_media_mins'      => $questionnaire->social_media_mins,
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

    /**
     * Validasi bahwa response Flask mengandung field wajib.
     *
     * Flask harus return:
     * {
     *   "digital_dependence_score": float,
     *   "category": string,
     *   "confidence": float,
     *   "ai_analysis": { ... }
     * }
     */
    private function isValidResponse(array $data): bool
    {
        $required = [
            'digital_dependence_score',
            'category',
            'confidence',
        ];

        foreach ($required as $field) {
            if (!array_key_exists($field, $data)) {
                Log::warning("ML response missing field: {$field}");
                return false;
            }
        }

        return true;
    }

    /**
     * Simpan hasil prediksi ke koleksi ml_results sebagai embedded document.
     */
    private function saveMlResult(Questionnaire $questionnaire, array $mlData): MlResult
    {
        // Hitung week_group: "2026-W17"
        $weekGroup = now()->format('Y') . '-W' . str_pad(now()->isoWeek(), 2, '0', STR_PAD_LEFT);

        // Upsert: kalau sudah ada result untuk questionnaire ini, update
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
                'ai_analysis' => $mlData['ai_analysis'] ?? [
                    'penyebab' => [],
                    'pembukaan' => '',
                    'rekomendasi' => [],
                    'generated_at' => now()->toISOString(),
                ],
                'week_group' => $weekGroup,
            ]
        );
    }
}