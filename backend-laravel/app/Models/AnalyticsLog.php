<?php
// ══════════════════════════════════════════════════════════════
// FILE: app/Models/AnalyticsLog.php
// ══════════════════════════════════════════════════════════════

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class AnalyticsLog extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'analytics_logs';
    protected $primaryKey = '_id';

    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'avg_dependence_7_days',
        'dependence_change_percentage',
        'created_at',
    ];

    protected $casts = [
        'avg_dependence_7_days'        => 'float',
        'dependence_change_percentage' => 'float',
        'created_at'                   => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}