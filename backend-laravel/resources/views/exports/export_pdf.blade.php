<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laporan Analisis Digital - {{ $user->name }}</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap');
        
        body {
            font-family: 'Inter', sans-serif;
            color: #1F2937;
            line-height: 1.5;
            margin: 0;
            padding: 40px;
            background-color: #F9FAFB;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 50px;
            border-radius: 24px;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #F3F4F6;
            padding-bottom: 30px;
            margin-bottom: 40px;
        }

        .logo {
            font-size: 24px;
            font-weight: 800;
            color: #0D9488;
            letter-spacing: -1px;
        }

        .report-title {
            text-align: right;
        }

        .report-title h1 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
            color: #111827;
        }

        .report-title p {
            margin: 5px 0 0;
            font-size: 14px;
            color: #6B7280;
        }

        .user-info {
            margin-bottom: 40px;
        }

        .user-info h2 {
            font-size: 24px;
            font-weight: 800;
            margin: 0 0 10px;
            color: #111827;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 40px;
        }

        .stat-card {
            padding: 24px;
            border-radius: 16px;
            background: #F0FDFA;
            border: 1px solid #CCFBF1;
        }

        .stat-card.secondary {
            background: #F3F4F6;
            border: 1px solid #E5E7EB;
        }

        .stat-label {
            font-size: 12px;
            font-weight: 700;
            color: #0D9488;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 8px;
        }

        .stat-value {
            font-size: 32px;
            font-weight: 800;
            color: #111827;
        }

        .status-badge {
            display: inline-block;
            padding: 6px 16px;
            border-radius: 99px;
            font-size: 14px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .status-membaik { background: #DCFCE7; color: #15803D; }
        .status-memburuk { background: #FEE2E2; color: #B91C1C; }
        .status-stabil { background: #FEF3C7; color: #92400E; }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th {
            text-align: left;
            font-size: 12px;
            font-weight: 700;
            color: #6B7280;
            text-transform: uppercase;
            padding: 12px 16px;
            border-bottom: 2px solid #F3F4F6;
        }

        td {
            padding: 16px;
            font-size: 14px;
            border-bottom: 1px solid #F3F4F6;
        }

        .footer {
            margin-top: 60px;
            text-align: center;
            font-size: 12px;
            color: #9CA3AF;
        }

        @media print {
            body { background: white; padding: 0; }
            .container { box-shadow: none; border-radius: 0; padding: 0; }
            .no-print { display: none; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">ACTIVA.</div>
            <div class="report-title">
                <h1>Laporan Analisis Gaya Hidup</h1>
                <p>Dicetak pada {{ $date }}</p>
            </div>
        </div>

        <div class="user-info">
            <p style="color: #6B7280; margin-bottom: 5px; font-size: 14px;">Nama Pengguna</p>
            <h2>{{ $user->name }}</h2>
            <p style="color: #6B7280; font-size: 14px;">{{ $user->email }} • {{ $user->region }}</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Skor Rata-rata Minggu Ini</div>
                <div class="stat-value">{{ $thisScore }}</div>
                <div style="margin-top: 10px;">
                    <span class="status-badge status-{{ $status }}">Trend {{ ucfirst($status) }}</span>
                </div>
            </div>
            <div class="stat-card secondary">
                <div class="stat-label">Skor Rata-rata Minggu Lalu</div>
                <div class="stat-value">{{ $lastScore }}</div>
            </div>
        </div>

        <h3 style="font-size: 18px; font-weight: 700; margin-bottom: 20px;">Riwayat 14 Data Terakhir</h3>
        <table>
            <thead>
                <tr>
                    <th>Tanggal</th>
                    <th>Skor</th>
                    <th>Kategori</th>
                </tr>
            </thead>
            <tbody>
                @foreach($results as $r)
                <tr>
                    <td>{{ $r->created_at->format('d M Y') }}</td>
                    <td><strong>{{ $r->ml_result['digital_dependence_score'] ?? 0 }}</strong></td>
                    <td>{{ ucfirst($r->ml_result['category'] ?? '-') }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>

        <div class="footer">
            <p>© {{ date('Y') }} Activa DigitalLife Analyzer. Seluruh data dianalisis menggunakan Machine Learning.</p>
        </div>
    </div>
</body>
</html>
