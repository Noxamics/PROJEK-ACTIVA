<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\MlResult;
use App\Models\Questionnaire;
use Illuminate\Support\Facades\Response;
use Barryvdh\DomPDF\Facade\Pdf;

class ExportController extends Controller
{
    /**
     * Export data (PDF or Excel)
     */
    public function export(Request $request)
    {
        $format = $request->query('format', 'pdf');
        $userId = Auth::id();

        // Validasi: Cek apakah user sudah pernah mengisi kuesioner
        $count = Questionnaire::where('user_id', $userId)->count();
        if ($count === 0) {
            return response()->json([
                'success' => false,
                'message' => 'Isi setidaknya satu kuesioner untuk mengekspor data.'
            ], 400);
        }

        if ($format === 'excel') {
            return $this->exportExcel($userId);
        }

        return $this->exportPdf($userId);
    }

    private function exportExcel($userId)
    {
        $results = MlResult::where('user_id', $userId)
            ->with('questionnaire')
            ->orderBy('created_at', 'desc')
            ->get();

        $filename = "activa_data_history_" . date('Ymd_His') . ".csv";
        
        $handle = fopen('php://output', 'w');
        
        // Header
        fputcsv($handle, [
            'Tanggal', 
            'Skor Dependensi', 
            'Kategori', 
        ]);

        foreach ($results as $r) {
            fputcsv($handle, [
                $r->created_at->format('d/m/Y H:i'),
                $r->ml_result['digital_dependence_score'] ?? 0,
                ucfirst($r->ml_result['category'] ?? '-'),
            ]);
        }

        return Response::streamDownload(function() use ($handle) {
            fclose($handle);
        }, $filename, [
            'Content-Type' => 'text/csv',
        ]);
    }

    private function exportPdf($userId)
    {
        // Ambil data yang sama dengan LaporanController untuk summary
        $results = MlResult::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->limit(14)
            ->get();

        if ($results->count() < 14) {
            return response()->json([
                'success' => false,
                'message' => 'Data belum cukup untuk membuat laporan PDF (Minimal 14 data).',
            ], 422);
        }

        // Logic split & average (Sama dengan LaporanController)
        $thisWeek = $results->slice(0, 7);
        $lastWeek = $results->slice(7, 7);

        $thisScore = $thisWeek->avg(fn($r) => $r->ml_result['digital_dependence_score'] ?? 0);
        $lastScore = $lastWeek->avg(fn($r) => $r->ml_result['digital_dependence_score'] ?? 0);
        
        $scoreDiff = $thisScore - $lastScore;
        $scoreStatus = $scoreDiff > 2 ? 'memburuk' : ($scoreDiff < -2 ? 'membaik' : 'stabil');

        $user = Auth::user();

        // Kita gunakan Pdf facade untuk generate PDF dari view
        $pdf = Pdf::loadView('exports.export_pdf', [
            'user' => $user,
            'thisScore' => round($thisScore, 1),
            'lastScore' => round($lastScore, 1),
            'status' => $scoreStatus,
            'results' => $results,
            'date' => date('d F Y'),
        ]);

        return $pdf->download("activa_report_" . date('Ymd_His') . ".pdf");
    }
}
