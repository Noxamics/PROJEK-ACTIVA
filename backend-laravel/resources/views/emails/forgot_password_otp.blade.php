<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Reset Password OTP</title>
</head>
<body style="font-family: Arial, sans-serif; background-color: #f4f7f6; margin: 0; padding: 20px;">
    <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
        <div style="text-align: center; margin-bottom: 20px;">
            <h2 style="color: #0b2e59; margin: 0;">ACTIVA</h2>
            <p style="color: #718096; font-size: 14px; margin-top: 5px;">DigitalLife Analyzer</p>
        </div>
        
        <h3 style="color: #1a202c; font-size: 18px; margin-top: 0;">Halo {{ $user->name ?? 'Pengguna' }},</h3>
        <p style="color: #4a5568; font-size: 15px; line-height: 1.6;">
            Kami menerima permintaan untuk mereset password akun ACTIVA Anda. Berikut adalah kode OTP Anda:
        </p>
        
        <div style="text-align: center; margin: 30px 0;">
            <span style="display: inline-block; padding: 15px 30px; font-size: 32px; font-weight: bold; color: #1abc8c; background-color: #e6f7f3; border-radius: 8px; letter-spacing: 5px;">
                {{ $otp }}
            </span>
        </div>
        
        <p style="color: #4a5568; font-size: 14px; line-height: 1.5; text-align: center;">
            Kode OTP ini hanya berlaku selama <strong>10 menit</strong>. Jangan bagikan kode ini kepada siapa pun.
        </p>
        
        <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 30px 0;">
        
        <p style="color: #a0aec0; font-size: 12px; text-align: center; margin: 0;">
            Jika Anda tidak meminta reset password, Anda dapat mengabaikan email ini.<br>
            &copy; {{ date('Y') }} ACTIVA. Hak Cipta Dilindungi.
        </p>
    </div>
</body>
</html>
