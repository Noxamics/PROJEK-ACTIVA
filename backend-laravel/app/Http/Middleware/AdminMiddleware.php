<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;

/**
 * PATH: app/Http/Middleware/AdminMiddleware.php
 *
 * Middleware tunggal untuk proteksi semua route /admin/*
 * Gantikan AdminOnlyMiddleware + AuthMiddleware yang duplikat.
 *
 * Daftarkan di bootstrap/app.php atau Kernel.php:
 *   'admin' => \App\Http\Middleware\AdminMiddleware::class,
 */
class AdminMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        if (!Session::has('admin_id')) {
            return redirect()->route('login')
                ->with('error', 'unauthorized');
        }

        return $next($request);
    }
}