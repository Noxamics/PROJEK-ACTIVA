<?php
// ══════════════════════════════════════════════════════════════
// FILE: app/Http/Requests/StoreSurveyRequest.php
// ══════════════════════════════════════════════════════════════

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class StoreSurveyRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            // Device type — auto-detect dari Flutter
            'device_type'              => 'nullable|string|max:50',

            // Penggunaan perangkat — wajib diisi
            'device_hours_per_day'     => 'required|numeric|min:0|max:24',
            'phone_unlocks_per_day'    => 'required|integer|min:0',
            'notifications_per_day'    => 'required|integer|min:0',
            'social_media_minutes'     => 'required|integer|min:0|max:1440',

            // Aktivitas
            'study_minutes'            => 'required|integer|min:0|max:1440',
            'physical_activity_days'   => 'required|integer|min:0|max:7',

            // Tidur
            'sleep_hours'              => 'required|numeric|min:0|max:24',
            'sleep_quality'            => 'required|numeric|min:1|max:10',

            // Kesehatan mental (skala)
            'anxiety_score'            => 'required|numeric|min:0|max:27',
            'depression_score'         => 'required|numeric|min:0|max:27',
            'stress_level'             => 'required|numeric|min:0|max:10',
            'happiness_score'          => 'required|numeric|min:0|max:10',
        ];
    }

    public function messages(): array
    {
        return [
            'device_hours_per_day.required' => 'Jam penggunaan perangkat wajib diisi',
            'sleep_hours.required'          => 'Jam tidur wajib diisi',
            'sleep_quality.required'        => 'Kualitas tidur wajib diisi',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'success' => false,
            'message' => 'Validasi gagal',
            'errors'  => $validator->errors(),
        ], 422));
    }
}