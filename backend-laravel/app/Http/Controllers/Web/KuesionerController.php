<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Questionnaire;
use App\Services\MlService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class KuesionerController extends Controller
{
    public function index()
    {
        return view('web.kuesioner');
    }

    public function store(Request $request, MlService $mlService)
    {
        $request->validate([
            'device_type' => 'nullable|string|in:Smartphone,Laptop,Both',
            'device_hours_per_day' => 'required|numeric',
            'phone_unlocks' => 'required|numeric',
            'notifications_per_day' => 'required|numeric',
            'social_media_mins' => 'required|numeric',
            'study_minutes' => 'required|numeric',
            'physical_activity_days' => 'required|numeric',
            'sleep_hours' => 'required|numeric',
            'sleep_quality' => 'required|numeric',
            'anxiety_score' => 'required|numeric',
            'depression_score' => 'required|numeric',
            'stress_level' => 'required|numeric',
            'happiness_score' => 'required|numeric',
        ]);

        $user = Auth::user();

        $questionnaire = Questionnaire::create([
            'user_id' => (string) $user->_id,
            'device_type' => $request->device_type ?? 'Smartphone',
            'device_hours_per_day' => (float) $request->device_hours_per_day,
            'phone_unlocks' => (int) $request->phone_unlocks,
            'notifications_per_day' => (int) $request->notifications_per_day,
            'social_media_mins' => (float) $request->social_media_mins,
            'study_minutes' => (float) $request->study_minutes,
            'physical_activity_days' => (int) $request->physical_activity_days,
            'sleep_hours' => (float) $request->sleep_hours,
            'sleep_quality' => (float) $request->sleep_quality,
            'anxiety_score' => (float) $request->anxiety_score,
            'depression_score' => (float) $request->depression_score,
            'stress_level' => (float) $request->stress_level,
            'happiness_score' => (float) $request->happiness_score,
        ]);

        // Trigger ML prediction
        try {
            $mlService->predict($questionnaire);
            $questionnaire->refresh();
        } catch (\Exception $e) {
            return redirect('/user/hasil/' . $questionnaire->_id)
                ->with('warning', 'Kuesioner tersimpan, tapi prediksi ML gagal: ' . $e->getMessage());
        }

        return redirect('/user/hasil/' . $questionnaire->_id)
            ->with('success', 'Analisis selesai! 🎉');
    }
}
