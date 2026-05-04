<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

/**
 * PATH: app/Models/Admin.php
 *
 * Model untuk admin yang login via OTP.
 * Data admin di-seed dari ENV (ADMIN_EMAIL, ADMIN_NAME).
 */
class Admin extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'admins';

    protected $fillable = [
        'full_name',
        'email',
        'is_active',
        'otp_code',
        'otp_expires_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];
}