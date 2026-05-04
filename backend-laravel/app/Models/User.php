<?php
// ══════════════════════════════════════════════════════════════
// FILE: app/Models/User.php
// ══════════════════════════════════════════════════════════════

namespace App\Models;

use Illuminate\Notifications\Notifiable;
use MongoDB\Laravel\Auth\User as Authenticatable;
use Tymon\JWTAuth\Contracts\JWTSubject;
use Illuminate\Support\Carbon;

class User extends Authenticatable implements JWTSubject
{
    use Notifiable;

    protected $connection = 'mongodb';
    protected $collection = 'users';

    protected $fillable = [
        'name', 'email', 'password',
        'gender', 'tgl_lahir', 'age', 'region', 'education_level',
        'daily_role', 'income_level',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'tgl_lahir'  => 'datetime',
        'age'        => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'last_login' => 'datetime',
    ];

    // Kita tidak perlu lagi accessor getAgeAttribute jika sudah disimpan di DB,
    // tapi kita biarkan saja sebagai fallback atau bisa dihapus.
    public function getAgeAttribute(): ?int
    {
        return $this->attributes['age'] ?? (isset($this->tgl_lahir) ? Carbon::parse($this->tgl_lahir)->age : null);
    }

    // JWT Interface
    public function getJWTIdentifier()        { return $this->getKey(); }
    public function getJWTCustomClaims(): array { return []; }

    // Relasi ke questionnaires
    public function questionnaires()
    {
        return $this->hasMany(Questionnaire::class, 'user_id');
    }

    // Relasi ke ml_results
    public function mlResults()
    {
        return $this->hasMany(MlResult::class, 'user_id');
    }
}