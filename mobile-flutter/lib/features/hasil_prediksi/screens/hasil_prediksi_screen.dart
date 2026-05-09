// lib/features/hasil_prediksi/screens/hasil_prediksi_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../kuisioner/providers/questionnaire_provider.dart';
import '../models/ml_result_model.dart';
import '../providers/result_provider.dart';
import '../widgets/score_circle.dart';
import '../../histori/screens/histori_screen.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../profil/screens/profil_screen.dart';

/// Warna berdasarkan skor dependensi digital
Color _scoreColor(double score) {
  if (score < 33.47) return AppColors.teal;
  if (score <= 61.34) return AppColors.amber;
  return AppColors.red;
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading Widget: ditampilkan saat FutureBuilder dalam state loading
// ─────────────────────────────────────────────────────────────────────────────

class _AnalysisLoadingView extends StatefulWidget {
  const _AnalysisLoadingView();

  @override
  State<_AnalysisLoadingView> createState() => _AnalysisLoadingViewState();
}

class _AnalysisLoadingViewState extends State<_AnalysisLoadingView>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _stepController;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _stepAnim;

  int _currentStep = 0;

  /// Tahapan proses yang ditampilkan ke user secara berurutan
  static const _steps = [
    (Icons.upload_rounded, 'Mengirim data kuesioner ke server...'),
    (
      Icons.psychology_rounded,
      'Model AI sedang menganalisis pola digitalmu...',
    ),
    (Icons.auto_graph_rounded, 'Menghitung skor ketergantungan digital...'),
    (
      Icons.check_circle_outline_rounded,
      'Menyiapkan hasil & rekomendasi untukmu...',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _stepAnim = CurvedAnimation(parent: _stepController, curve: Curves.easeOut);

    // Siklus maju antar step setiap ~2.2 detik
    _cycleSteps();
  }

  void _cycleSteps() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) break;
      setState(() {
        _currentStep = (_currentStep + 1) % _steps.length;
      });
      _stepController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Pulsing brain icon ─────────────────────────────────────────
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal.withValues(alpha: 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(
                        alpha: _pulseAnim.value * 0.35,
                      ),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  color: AppColors.teal.withValues(alpha: _pulseAnim.value),
                  size: 48,
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── Judul ──────────────────────────────────────────────────────
            const Text(
              'Sedang Menganalisis...',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Mohon tunggu, jangan tutup aplikasi ini',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),

            const SizedBox(height: 36),

            // ── Step progress card ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: List.generate(_steps.length, (i) {
                  final isDone = i < _currentStep;
                  final isActive = i == _currentStep;
                  final color = isDone || isActive
                      ? AppColors.teal
                      : AppColors.textSecondary.withValues(alpha: 0.3);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        // Step icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isDone || isActive)
                                ? AppColors.teal.withValues(alpha: 0.15)
                                : Colors.transparent,
                            border: Border.all(
                              color: color,
                              width: isActive ? 2 : 1.5,
                            ),
                          ),
                          child: isDone
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.teal,
                                  size: 16,
                                )
                              : Icon(_steps[i].$1, color: color, size: 16),
                        ),
                        const SizedBox(width: 12),
                        // Step label
                        Expanded(
                          child: Text(
                            _steps[i].$2,
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.textPrimary
                                  : isDone
                                  ? AppColors.teal.withValues(alpha: 0.7)
                                  : AppColors.textSecondary.withValues(
                                      alpha: 0.4,
                                    ),
                              fontSize: 13,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        // Active spinner
                        if (isActive)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.teal,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 28),

            // ── Progress bar ───────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: 6,
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  backgroundColor: AppColors.teal.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Langkah ${_currentStep + 1} dari ${_steps.length}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Widget: ditampilkan saat FutureBuilder dalam state error
// ─────────────────────────────────────────────────────────────────────────────

class _AnalysisErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _AnalysisErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.red.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.red.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.red,
                size: 44,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Analisis Gagal',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tidak dapat terhubung ke server.\nPastikan koneksimu stabil dan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            // Detail error (opsional, hanya untuk debugging)
            if (error != null)
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.red.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red.withValues(alpha: 0.15),
                  foregroundColor: AppColors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class HasilPrediksiScreen extends ConsumerStatefulWidget {
  /// Jika null, Future akan memanggil service untuk fetch hasil
  final MlResultModel? result;

  const HasilPrediksiScreen({super.key, this.result});

  @override
  ConsumerState<HasilPrediksiScreen> createState() =>
      _HasilPrediksiScreenState();
}

class _HasilPrediksiScreenState extends ConsumerState<HasilPrediksiScreen> {
  late Future<MlResultModel> _resultFuture;

  @override
  void initState() {
    super.initState();
    _resultFuture = _loadResult();
  }

  /// Jika result sudah di-pass langsung (dari navigator argument), langsung
  /// return. Kalau tidak, ambil dari provider / service.
  Future<MlResultModel> _loadResult() async {
    if (widget.result != null) return widget.result!;

    // Tunggu sebentar agar provider sempat update (opsional, sesuaikan kebutuhan)
    await Future.delayed(const Duration(milliseconds: 300));

    final fromQuestionnaire = ref.read(questionnaireResultProvider);
    if (fromQuestionnaire != null) return fromQuestionnaire;

    final fromLatest = ref.read(resultProvider).latestResult;
    if (fromLatest != null) return fromLatest;

    throw Exception('Hasil analisis tidak ditemukan. Silakan coba lagi.');
  }

  void _retry() {
    setState(() {
      _resultFuture = _loadResult();
    });
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KuesionerScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPerkembanganScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GrafikScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<MlResultModel>(
                future: _resultFuture,
                builder: (context, snapshot) {
                  // ── Loading ───────────────────────────────────────────────
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _AnalysisLoadingView();
                  }

                  // ── Error ─────────────────────────────────────────────────
                  if (snapshot.hasError) {
                    return _AnalysisErrorView(
                      error: snapshot.error,
                      onRetry: _retry,
                    );
                  }

                  // ── Data tersedia ─────────────────────────────────────────
                  final data = snapshot.data!;
                  return Column(
                    children: [
                      _buildHeader(data),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              _buildLargeScoreCircle(data),
                              const SizedBox(height: 24),
                              _buildRiskBadge(data),
                              const SizedBox(height: 24),
                              _buildConfidenceDetail(data),
                              const SizedBox(height: 24),
                              if (data.pembukaan.isNotEmpty)
                                _buildPembukaanCard(data),
                              const SizedBox(height: 24),
                              _buildRekomendasiCard(data),
                              const SizedBox(height: 24),
                              _buildHistoriButton(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            BottomNav(currentIndex: 1, onTap: _onNavTap),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(MlResultModel data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 16, 20, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hasil Analisis',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Gaya Hidup Digital Kamu',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
            ),
            child: Text(
              data.formattedDate,
              style: const TextStyle(
                color: AppColors.teal,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Score ────────────────────────────────────────────────────────────────────

  Widget _buildLargeScoreCircle(MlResultModel data) {
    final color = _scoreColor(data.digitalDependenceScore);
    return Center(
      child: ScoreCircle(
        score: data.dependenceInt.toString(),
        label: 'Skor Dependensi Digital',
        color: color,
        percent: (data.digitalDependenceScore / 100).clamp(0.0, 1.0),
        size: 160,
        fontSize: 48,
      ),
    );
  }

  Widget _buildRiskBadge(MlResultModel data) {
    final cat = data.category.toLowerCase();
    final isHigh = cat == 'tinggi' || cat == 'high';
    final isMedium = cat == 'sedang' || cat == 'moderate';
    final color = _scoreColor(data.digitalDependenceScore);

    final label = isHigh
        ? 'Tinggi — Risiko Ketergantungan'
        : (isMedium ? 'Sedang — Perlu Perhatian' : 'Rendah — Pola Hidup Sehat');

    final icon = isHigh
        ? Icons.warning_amber_rounded
        : (isMedium
              ? Icons.info_outline_rounded
              : Icons.check_circle_outline_rounded);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceDetail(MlResultModel data) {
    final confidence = data.confidence.confidenceFinalPct;
    final color = _scoreColor(data.digitalDependenceScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tingkat Kepercayaan Analisis (Confidence)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${confidence.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          if (data.confidence.label.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Status: ${data.confidence.label}',
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Pembukaan AI ──────────────────────────────────────────────────────────────

  Widget _buildPembukaanCard(MlResultModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_rounded, color: AppColors.teal, size: 20),
              SizedBox(width: 10),
              Text(
                'Analisis AI',
                style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.pembukaan,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // ── Rekomendasi ───────────────────────────────────────────────────────────────

  Widget _buildRekomendasiCard(MlResultModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.teal, size: 20),
              SizedBox(width: 10),
              Text(
                'Rekomendasi Untukmu',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...data.recommendations.map(_buildRekItem),
        ],
      ),
    );
  }

  Widget _buildRekItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Histori Button ────────────────────────────────────────────────────────────

  Widget _buildHistoriButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoriScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bgCard,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Lihat Riwayat Analisis',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
