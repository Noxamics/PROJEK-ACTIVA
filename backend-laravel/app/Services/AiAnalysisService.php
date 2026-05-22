<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AiAnalysisService
{
    protected const TAG_DESCRIPTIONS = [
        'screen_time_high' => 'terlalu lama menatap layar HP/gadget',
        'notification_overload' => 'terlalu banyak notifikasi yang mengganggu fokus',
        'sleep_low' => 'kurang tidur',
        'sleep_bad_quality' => 'kualitas tidur yang buruk',
        'anxiety_high' => 'tingkat kecemasan yang tinggi',
        'depression_high' => 'tanda-tanda depresi yang perlu diperhatikan',
        'stress_high' => 'tingkat stres yang tinggi',
        'happiness_low' => 'tingkat kebahagiaan yang rendah',
        'general' => 'gaya hidup digital yang perlu diseimbangkan',
    ];

    public function generate(
        float $score,
        string $category,
        array $penyebab,
        array $rawInput,
    ): array {
        $prompt = $this->buildPrompt($score, $category, $penyebab, $rawInput);

        // Driver: 'groq' | 'gemini' | 'openai'
        $driver = config('services.ai.driver', 'groq');

        $raw = match ($driver) {
            'openai' => $this->callOpenAI($prompt),
            'gemini' => $this->callGemini($prompt),
            default => $this->callGroq($prompt),
        };

        return $this->parseResponse($raw, $penyebab);
    }

    // ============================================================
    // PROMPT BUILDER
    // ============================================================
    protected function buildPrompt(
        float $score,
        string $category,
        array $penyebab,
        array $rawInput,
    ): string {
        $penyebabKalimat = collect($penyebab)
            ->map(fn($tag) => "- {$tag}: " . (self::TAG_DESCRIPTIONS[$tag] ?? $tag))
            ->implode("\n");

        $contohOutput = collect($penyebab)
            ->map(fn($tag) => '    { "tag": "' . $tag . '", "isi": "saran santai spesifik untuk ' . (self::TAG_DESCRIPTIONS[$tag] ?? $tag) . '" }')
            ->implode(",\n");

        $penyebabJson = json_encode($penyebab, JSON_UNESCAPED_UNICODE);

        $hp = $rawInput['device_hours_per_day'] ?? '-';
        $socmed = $rawInput['social_media_mins'] ?? '-';
        $tidur = $rawInput['sleep_hours'] ?? '-';
        $kualitas = $rawInput['sleep_quality'] ?? '-';
        $notif = $rawInput['notifications_per_day'] ?? '-';
        $stres = $rawInput['stress_level'] ?? '-';
        $cemas = $rawInput['anxiety_score'] ?? '-';
        $depresi = $rawInput['depression_score'] ?? '-';
        $bahagia = $rawInput['happiness_score'] ?? '-';

        return <<<PROMPT
Kamu adalah asisten kesehatan digital yang ramah, santai, dan supportif — seperti teman yang peduli.

User punya skor ketergantungan digital: {$score} (kategori: {$category}).

Penyebab yang terdeteksi:
{$penyebabKalimat}

Data kondisi user:
- Pakai HP: {$hp} jam/hari
- Media sosial: {$socmed} menit/hari
- Tidur: {$tidur} jam/hari
- Kualitas tidur: {$kualitas} dari 5
- Notifikasi: {$notif} per hari
- Stres: {$stres} dari 10
- Kecemasan: {$cemas}
- Depresi: {$depresi}
- Kebahagiaan: {$bahagia} dari 10

Tugasmu:
- Tulis "pembukaan": 2-3 kalimat santai yang menjelaskan hasil skor ketergantungan digital user dan menyebutkan semua penyebab yang terdeteksi — seperti teman yang lagi ngasih tau kondisi kamu
- Tulis "rekomendasi": array berisi saran TERPISAH untuk SETIAP penyebab, spesifik ke penyebabnya masing-masing, 1-2 kalimat santai per penyebab
- Kalau ada tanda depresi/kecemasan, singgung dengan lembut
- Jangan diagnosis medis, jangan menggurui

Output HARUS dalam format JSON (tanpa teks apapun di luar JSON):
{
  "penyebab": {$penyebabJson},
  "pembukaan": "2-3 kalimat santai tentang hasil skor dan ringkasan semua penyebab",
  "rekomendasi": [
{$contohOutput}
  ]
}
PROMPT;
    }

    // ============================================================
    // GROQ DRIVER
    // ============================================================
    protected function callGroq(string $prompt): string
    {
        $response = Http::withToken(config('services.ai.groq_key'))
            ->timeout(30)
            ->post('https://api.groq.com/openai/v1/chat/completions', [
                'model' => config('services.ai.groq_model', 'llama-3.3-70b-versatile'),
                'max_tokens' => 1024,
                'temperature' => 0.7,
                'messages' => [
                    [
                        'role' => 'system',
                        'content' => 'Kamu adalah asisten kesehatan digital yang ramah dan empatik. Selalu jawab HANYA dalam format JSON yang diminta, tanpa teks tambahan apapun di luar JSON.',
                    ],
                    [
                        'role' => 'user',
                        'content' => $prompt,
                    ],
                ],
            ]);

        if ($response->failed()) {
            Log::error('Groq API error', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            throw new \RuntimeException('Groq API error: ' . $response->body());
        }

        return $response->json('choices.0.message.content') ?? '';
    }

    // ============================================================
    // GEMINI DRIVER
    // ============================================================
    protected function callGemini(string $prompt): string
    {
        $apiKey = config('services.ai.gemini_key');
        $model = config('services.ai.gemini_model', 'gemini-1.5-flash');

        $response = Http::timeout(30)
            ->post(
                "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent?key={$apiKey}",
                [
                    'system_instruction' => [
                        'parts' => [
                            [
                                'text' => 'Kamu adalah asisten kesehatan digital yang ramah dan empatik. Selalu jawab HANYA dalam format JSON yang diminta, tanpa teks tambahan apapun di luar JSON.',
                            ]
                        ],
                    ],
                    'contents' => [
                        [
                            'parts' => [['text' => $prompt]],
                        ]
                    ],
                    'generationConfig' => [
                        'temperature' => 0.7,
                        'maxOutputTokens' => 1024,
                    ],
                ]
            );

        if ($response->failed()) {
            Log::error('Gemini API error', ['body' => $response->body()]);
            throw new \RuntimeException('Gemini API error: ' . $response->body());
        }

        return $response->json('candidates.0.content.parts.0.text') ?? '';
    }

    // ============================================================
    // OPENAI DRIVER
    // ============================================================
    protected function callOpenAI(string $prompt): string
    {
        $response = Http::withToken(config('services.ai.openai_key'))
            ->timeout(30)
            ->post('https://api.openai.com/v1/chat/completions', [
                'model' => config('services.ai.openai_model', 'gpt-4o-mini'),
                'max_tokens' => 1024,
                'temperature' => 0.7,
                'messages' => [
                    [
                        'role' => 'system',
                        'content' => 'Kamu adalah asisten kesehatan digital yang ramah dan empatik. Selalu jawab HANYA dalam format JSON yang diminta, tanpa teks tambahan apapun di luar JSON.',
                    ],
                    [
                        'role' => 'user',
                        'content' => $prompt,
                    ],
                ],
            ]);

        if ($response->failed()) {
            Log::error('OpenAI API error', ['body' => $response->body()]);
            throw new \RuntimeException('OpenAI API error: ' . $response->body());
        }

        return $response->json('choices.0.message.content') ?? '';
    }

    // ============================================================
    // PARSE JSON dari respons AI
    // ============================================================
    protected function parseResponse(string $raw, array $penyebab): array
    {
        $cleaned = preg_replace('/```json|```/', '', $raw);
        $cleaned = trim($cleaned);

        $decoded = json_decode($cleaned, true);

        if (json_last_error() === JSON_ERROR_NONE && isset($decoded['pembukaan'])) {
            return $decoded;
        }

        Log::warning('AiAnalysisService: JSON parse gagal, fallback', ['raw' => $raw]);

        return [
            'penyebab' => $penyebab,
            'pembukaan' => $raw,
            'rekomendasi' => array_map(fn($tag) => [
                'tag' => $tag,
                'isi' => '',
            ], $penyebab),
        ];
    }
}