<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kode OTP Reset Password</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }

        .container {
            max-width: 600px;
            margin: 20px auto;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .header {
            background-color: #667eea;
            color: white;
            padding: 30px;
            text-align: center;
        }

        .header h1 {
            margin: 0;
            font-size: 24px;
        }

        .content {
            padding: 30px;
        }

        .content p {
            color: #333;
            font-size: 16px;
            line-height: 1.6;
            margin: 15px 0;
        }

        .otp-box {
            background-color: #f0f0f0;
            border: 2px solid #667eea;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            margin: 25px 0;
        }

        .otp-code {
            font-size: 36px;
            font-weight: bold;
            color: #667eea;
            letter-spacing: 8px;
            font-family: 'Courier New', monospace;
        }

        .warning {
            background-color: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
            font-size: 14px;
            color: #856404;
        }

        .footer {
            background-color: #f9f9f9;
            padding: 20px;
            text-align: center;
            border-top: 1px solid #eee;
            font-size: 12px;
            color: #666;
        }

        .signature {
            margin-top: 30px;
            text-align: left;
        }

        .signature p {
            margin: 5px 0;
        }
    </style>
</head>

<body>
    <div class="container">
        <div class="header">
            <h1>Reset Password</h1>
            <p>Kode OTP Keamanan Anda</p>
        </div>

        <div class="content">
            <p>Halo {{ $user->name }},</p>

            <p>Kami menerima permintaan untuk mereset password akun Anda. Gunakan kode OTP di bawah ini untuk
                melanjutkan:</p>

            <div class="otp-box">
                <div class="otp-code">{{ $otp }}</div>
            </div>

            <p><strong>Kode OTP berlaku selama 10 menit.</strong></p>

            <div class="warning">
                <strong>Perhatian Keamanan:</strong>
                <ul style="margin: 10px 0; padding-left: 20px;">
                    <li>Jangan bagikan kode ini kepada siapa pun, termasuk admin atau support</li>
                    <li>Kami tidak akan pernah meminta kode OTP melalui telepon atau chat</li>
                    <li>Jika Anda tidak melakukan permintaan ini, abaikan email ini</li>
                </ul>
            </div>

            <p>Jika Anda mengalami masalah atau tidak merasa melakukan permintaan ini, segera hubungi tim support kami.
            </p>

            <div class="signature">
                <p>Salam hormat,</p>
                <p><strong>Tim Activa</strong></p>
            </div>
        </div>

        <div class="footer">
            <p>&copy; {{ date('Y') }} Activa. Hak cipta dilindungi.</p>
            <p>Email ini dikirim karena ada permintaan reset password di akun Anda.</p>
        </div>
    </div>
</body>

</html>