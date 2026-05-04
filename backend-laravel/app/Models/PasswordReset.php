<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;
use Illuminate\Support\Carbon;

class PasswordReset extends Model
{
    /**
     * Database connection
     */
    protected $connection = 'mongodb';

    /**
     * Nama collection MongoDB
     */
    protected $collection = 'password_resets';

    /**
     * Primary key MongoDB
     */
    protected $primaryKey = '_id';

    /**
     * Laravel timestamps
     * Kita tidak pakai created_at & updated_at otomatis
     */
    public $timestamps = false;

    /**
     * Field yang boleh diisi mass assignment
     */
    protected $fillable = [
        'email',
        'otp_code',
        'expired_at',
        'verified',
    ];

    /**
     * Casting tipe data
     */
    protected $casts = [
        'expired_at' => 'datetime',
        'verified'   => 'boolean',
    ];

    /**
     * Scope: hanya OTP yang belum expired
     */
    public function scopeValid($query)
    {
        return $query->where('expired_at', '>', Carbon::now());
    }
}