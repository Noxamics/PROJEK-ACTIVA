<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class ProfilController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        return view('web.profil', compact('user'));
    }

    public function update(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'gender' => 'required|in:Laki-laki,Perempuan',
            'region' => 'required|string',
            'education_level' => 'required|string',
            'daily_role' => 'required|string',
        ]);

        $user = Auth::user();
        $user->update($request->only('name', 'gender', 'region', 'education_level', 'daily_role'));

        return back()->with('success', 'Profil berhasil diupdate');
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'old_password' => 'required',
            'password' => 'required|min:6|confirmed',
        ]);

        $user = Auth::user();
        if (!Hash::check($request->old_password, $user->password)) {
            return back()->withErrors(['old_password' => 'Password lama salah']);
        }

        $user->update(['password' => Hash::make($request->password)]);
        return back()->with('success', 'Password berhasil diganti');
    }
}
