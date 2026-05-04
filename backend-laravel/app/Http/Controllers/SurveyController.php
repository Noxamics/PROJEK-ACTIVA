<?php

namespace App\Http\Controllers;

use App\Models\Questionnaire;
use App\Models\MlResult;
use App\Services\MlService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class SurveyController extends Controller
{
    public function __construct(private MlService $mlService)
    {
    }

    public function index(): JsonResponse
    {
        $user = auth()->user();

        $surveys = Questionnaire::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        $data = $surveys->map(function ($q) {
            $ml = MlResult::where('questionnaire_id', $q->_id)->first();

            return [
                'questionnaire' => $this->formatQuestionnaire($q),
                'ml_result' => $ml ? $this->formatMlResult($ml) : null,
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Histori kuesioner ditemukan',
            'data' => $data,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'device_type' => 'nullable|string|max:50',
            'device_hours_per_day' => 'required|numeric|min:0|max:24',
            'phone_unlocks' => 'required|integer|min:0',
            'notifications_per_day' => 'required|integer|min:0',
            'social_media_mins' => 'required|integer|min:0',
            'study_minutes' => 'nullable|integer|min:0',
            'physical_activity_days' => 'nullable|integer|min:0|max:7',
            'sleep_hours' => 'nullable|numeric|min:0|max:24',
            'sleep_quality' => 'nullable|numeric|min:1|max:5',
            'anxiety_score' => 'required|numeric|min:0|max:27',
            'depression_score' => 'nullable|numeric|min:0|max:27',
            'stress_level' => 'nullable|numeric|min:1|max:10',
            'happiness_score' => 'nullable|numeric|min:0|max:10',
        ]);

        $user = auth()->user();

        $questionnaire = Questionnaire::create([
            'user_id' => $user->id,
            'device_type' => $validated['device_type']
                ?? (str_contains($request->userAgent() ?? '', 'iPhone')
                    ? 'iPhone' : 'Android'),
            'device_hours_per_day' => $validated['device_hours_per_day'],
            'phone_unlocks' => $validated['phone_unlocks'],
            'notifications_per_day' => $validated['notifications_per_day'],
            'social_media_mins' => $validated['social_media_mins'],
            'study_minutes' => $validated['study_minutes'] ?? 0,
            'physical_activity_days' => $validated['physical_activity_days'] ?? 0,
            'sleep_hours' => $validated['sleep_hours'] ?? 7.0,
            'sleep_quality' => $validated['sleep_quality'] ?? 3.0,
            'anxiety_score' => $validated['anxiety_score'],
            'depression_score' => $validated['depression_score'] ?? 0,
            'stress_level' => $validated['stress_level'] ?? 5,
            'happiness_score' => $validated['happiness_score'] ?? 5,
        ]);

        $mlResult = $this->mlService->predict($questionnaire);

        if (!$mlResult['success']) {
            return response()->json([
                'success' => false,
                'message' => $mlResult['error'] ?? 'Prediksi ML gagal',
                'data' => [
                    'questionnaire' => $this->formatQuestionnaire($questionnaire),
                    'ml_result' => null,
                ],
            ], 207);
        }

        return response()->json([
            'success' => true,
            'message' => 'Survey berhasil disubmit',
            'data' => [
                'questionnaire' => $this->formatQuestionnaire($questionnaire),
                'ml_result' => $this->formatMlResult($mlResult['data']),
            ],
        ], 201);
    }

    public function latest(): JsonResponse
    {
        $user = auth()->user();

        $questionnaire = Questionnaire::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->first();

        if (!$questionnaire) {
            return response()->json([
                'success' => false,
                'message' => 'Belum ada survey',
                'data' => null,
            ], 404);
        }

        $ml = MlResult::where('questionnaire_id', $questionnaire->_id)->first();

        return response()->json([
            'success' => true,
            'message' => 'Survey terbaru ditemukan',
            'data' => [
                'questionnaire' => $this->formatQuestionnaire($questionnaire),
                'ml_result' => $ml ? $this->formatMlResult($ml) : null,
            ],
        ]);
    }

    private function formatQuestionnaire(Questionnaire $q): array
    {
        return [
            '_id' => (string) $q->_id,
            'user_id' => (string) $q->user_id,
            'device_type' => $q->device_type,
            'device_hours_per_day' => $q->device_hours_per_day,
            'phone_unlocks' => $q->phone_unlocks,
            'notifications_per_day' => $q->notifications_per_day,
            'social_media_mins' => $q->social_media_mins,
            'study_minutes' => $q->study_minutes,
            'physical_activity_days' => $q->physical_activity_days,
            'sleep_hours' => $q->sleep_hours,
            'sleep_quality' => $q->sleep_quality,
            'anxiety_score' => $q->anxiety_score,
            'depression_score' => $q->depression_score,
            'stress_level' => $q->stress_level,
            'happiness_score' => $q->happiness_score,
            'created_at' => $q->created_at?->toISOString(),
        ];
    }

    private function formatMlResult($ml): array
    {
        return [
            '_id' => (string) $ml->_id,
            'questionnaire_id' => (string) $ml->questionnaire_id,
            'user_id' => (string) $ml->user_id,
            'digital_dependence_score' => $ml->ml_result['digital_dependence_score'] ?? 0,
            'category' => $ml->ml_result['category'] ?? 'rendah',
            'high_risk_flag' => $ml->ml_result['high_risk_flag'] ?? 0, // ← tambah
            'confidence' => $ml->ml_result['confidence'] ?? 0,
            'penyebab' => $ml->ai_analysis['penyebab'] ?? [],
            'pembukaan' => $ml->ai_analysis['pembukaan'] ?? '', // ← tambah
            'rekomendasi' => $ml->ai_analysis['rekomendasi'] ?? [],
            'week_group' => $ml->week_group,
            'created_at' => $ml->created_at?->toISOString(),
        ];
    }
}