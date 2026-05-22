<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'mailgun' => [
        'domain' => env('MAILGUN_DOMAIN'),
        'secret' => env('MAILGUN_SECRET'),
        'endpoint' => env('MAILGUN_ENDPOINT', 'api.mailgun.net'),
        'scheme' => 'https',
    ],

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'ai' => [
        // Ganti ke 'gemini' atau 'openai' kalau mau pakai driver lain
        'driver' => env('AI_DRIVER', 'groq'),

        // Groq
        'groq_key' => env('GROQ_API_KEY'),
        'groq_model' => env('GROQ_MODEL', 'llama-3.3-70b-versatile'),

        // Gemini (opsional)
        'gemini_key' => env('GEMINI_API_KEY'),
        'gemini_model' => env('GEMINI_MODEL', 'gemini-1.5-flash'),

        // OpenAI (opsional)
        'openai_key' => env('OPENAI_API_KEY'),
        'openai_model' => env('OPENAI_MODEL', 'gpt-4o-mini'),
    ],

    'ml' => [
        'url' => env('ML_SERVICE_URL', 'http://localhost:5000'),
        'timeout' => env('ML_SERVICE_TIMEOUT', 30),
    ],
];
