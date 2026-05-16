<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class WebUser
{
    public function handle(Request $request, Closure $next)
    {
        if (!Auth::guard('web')->check()) {
            return redirect('/user/landing')->with('error', 'Silakan login terlebih dahulu');
        }
        return $next($request);
    }
}
