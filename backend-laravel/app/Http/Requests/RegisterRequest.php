<?php
// ══════════════════════════════════════════════════════════════
// FILE: app/Http/Requests/RegisterRequest.php
// ══════════════════════════════════════════════════════════════

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'name'            => 'required|string|max:255',
            'email'           => 'required|email|unique:mongodb.users,email',
            'password'        => 'required|string|min:8|confirmed',
            'gender'          => 'nullable|in:Male,Female',
            'date_of_birth'   => 'nullable|date|before:today',
            'region'          => 'nullable|string|max:100',
            'education_level' => 'nullable|string|max:100',
            'daily_role'      => 'nullable|string|max:100',
            'income_level'    => 'nullable|string|max:100',
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique'        => 'Email sudah terdaftar',
            'password.min'        => 'Password minimal 8 karakter',
            'password.confirmed'  => 'Konfirmasi password tidak cocok',
            'date_of_birth.before'=> 'Tanggal lahir harus sebelum hari ini',
        ];
    }

    // Return JSON error (bukan redirect) — penting untuk API
    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'success' => false,
            'message' => 'Validasi gagal',
            'errors'  => $validator->errors(),
        ], 422));
    }
}