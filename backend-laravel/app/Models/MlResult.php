<?php
// ══════════════════════════════════════════════════════════════
// FILE: app/Models/MlResult.php
// ══════════════════════════════════════════════════════════════

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class MlResult extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'ml_results';

    protected $fillable = [
        'user_id',
        'questionnaire_id',
        'ml_result',      // embedded: { digital_dependence_score, category, confidence }
        'ai_analysis',    // embedded: { penyebab, rekomendasi, summary, model, generated_at }
        'week_group',     // "2026-W17"
    ];

    protected $casts = [
        'ml_result'   => 'array',
        'ai_analysis' => 'array',
    ];

    // ── Relasi ───────────────────────────────────────────────────────────────

    public function questionnaire()
    {
        return $this->belongsTo(Questionnaire::class, 'questionnaire_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    // ── Accessor helpers untuk embedded ml_result ─────────────────────────────

    public function getDependenceScoreAttribute(): float
    {
        return $this->ml_result['digital_dependence_score'] ?? 0.0;
    }

    public function getCategoryAttribute(): string
    {
        return $this->ml_result['category'] ?? 'rendah';
    }

    public function getConfidenceAttribute(): float
    {
        return $this->ml_result['confidence'] ?? 0.0;
    }

    // ── Accessor helpers untuk embedded ai_analysis ──────────────────────────

    public function getPenyebabAttribute(): array
    {
        return $this->ai_analysis['penyebab'] ?? [];
    }

    public function getRekomendasiAttribute(): array
    {
        return $this->ai_analysis['rekomendasi'] ?? [];
    }

    public function getSummaryAttribute(): string
    {
        return $this->ai_analysis['summary'] ?? '';
    }
}