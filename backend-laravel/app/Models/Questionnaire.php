<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Questionnaire extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'questionnaires';

    protected $fillable = [
        'user_id',
        'device_type',
        'device_hours_per_day', 'phone_unlocks', 'notifications_per_day',
        'social_media_mins', 'study_minutes', 'physical_activity_days',
        'sleep_hours', 'sleep_quality',
        'anxiety_score', 'depression_score', 'stress_level', 'happiness_score',
    ];

    protected $casts = [
        'device_hours_per_day'   => 'float',
        'phone_unlocks'          => 'integer',
        'notifications_per_day'  => 'integer',
        'social_media_mins'      => 'integer',
        'study_minutes'          => 'integer',
        'physical_activity_days' => 'integer',
        'sleep_hours'            => 'float',
        'sleep_quality'          => 'float',
        'anxiety_score'          => 'float',
        'depression_score'       => 'float',
        'stress_level'           => 'float',
        'happiness_score'        => 'float',
    ];

    /**
     * Event Booting untuk Model
     * Dijalankan otomatis oleh Laravel saat model ini diinisialisasi
     */
    protected static function boot()
    {
        parent::boot();

        // Event listener saat data kuesioner akan dihapus
        static::deleting(function ($questionnaire) {
            // Hapus juga data hasil ML yang terkait (Cascade Delete manual untuk MongoDB)
            if ($questionnaire->mlResult) {
                $questionnaire->mlResult()->delete();
            }
        });
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function mlResult()
    {
        return $this->hasOne(MlResult::class, 'questionnaire_id');
    }
}
