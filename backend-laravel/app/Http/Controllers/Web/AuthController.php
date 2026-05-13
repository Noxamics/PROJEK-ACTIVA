<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function showLogin()
    {
        if (Auth::check()) return redirect('/user/dashboard');
        return view('web.auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|min:6',
        ]);

        if (Auth::attempt($request->only('email', 'password'), $request->boolean('remember'))) {
            $request->session()->regenerate();
            return redirect('/user/dashboard')->with('success', 'Login berhasil!');
        }

        return back()->withErrors(['email' => 'Email atau password salah'])->withInput();
    }

    public function showRegister()
    {
        if (Auth::check()) return redirect('/user/dashboard');
        return view('web.auth.register');
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6|confirmed',
            'gender' => 'required|in:Laki-laki,Perempuan',
            'tgl_lahir' => 'required|date',
            'region' => 'required|string',
            'education_level' => 'required|string',
            'daily_role' => 'required|string',
            'income_level' => 'required|string',
        ]);

        $dob = new \DateTime($request->tgl_lahir);
        $age = (new \DateTime())->diff($dob)->y;

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'gender' => $request->gender,
            'tgl_lahir' => $dob->format('Y-m-d H:i:s'),
            'age' => $age,
            'region' => $request->region,
            'education_level' => $request->education_level,
            'daily_role' => $request->daily_role,
            'income_level' => $request->income_level,
        ]);

        Auth::login($user);
        return redirect('/user/dashboard')->with('success', 'Registrasi berhasil! 🎉');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/user/login')->with('success', 'Berhasil logout');
    }
}
