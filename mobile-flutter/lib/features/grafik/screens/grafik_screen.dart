// lib/features/grafik/screens/grafik_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../profil/screens/profil_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../../profil/widgets/floating_particles.dart';
import '../faker/grafik_faker.dart';
import '../providers/grafik_provider.dart';
import '../widgets/v2_charts.dart';

// Warna background konten — dipakai oleh wave clipper
const Color _kIce = AppColors.bgLight;

// ══════════════════════════════════════════════════════════════════════════════
// WAVE CLIPPER — Unified, identik dengan dashboard & layar lainnya
// ══════════════════════════════════════════════════════════════════════════════

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.moveTo(0, size.height * 0.5);
    p.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.5);
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class GrafikScreen extends ConsumerStatefulWidget {
  const GrafikScreen({super.key});

  @override
  ConsumerState<GrafikScreen> createState() => _GrafikScreenState();
}

class _GrafikScreenState extends ConsumerState<GrafikScreen> {
  static const _periodLabels = ['7 Hari', 'Bulanan', 'Tahun'];

  // Map index selector → GrafikPeriod
  static const _periodMap = [
    GrafikPeriod.week,
    GrafikPeriod.month,
    GrafikPeriod.year,
  ];

  @override
  Widget build(BuildContext context) {
    final grafikState = ref.watch(grafikProvider);
    final selectedPeriodIndex = _periodMap.indexOf(grafikState.period);

    return Scaffold(
      backgroundColor: _kIce,
      body: Column(
        children: [
          // ── Hero Header with wave ──
          SafeArea(
            bottom: false,
            child: _buildHeroHeader(),
          ),

          // ── Content area ──
          Expanded(
            child: Container(
              color: _kIce,
              child: RefreshIndicator(
                color: AppColors.teal,
                backgroundColor: AppColors.bgWhite,
                onRefresh: () => ref.read(grafikProvider.notifier).fetchGrafikData(grafikState.period),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    children: [
                      _buildPeriodSelector(selectedPeriodIndex),
                      const SizedBox(height: 32),
                      _buildContent(grafikState),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom Nav ──
          BottomNav(
            currentIndex: 3,
            navTheme: NavTheme.light,
            onTap: (i) => _onNavTap(context, i),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(GrafikState grafikState) {
    if (grafikState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
              ),
              SizedBox(height: 16),
              Text(
                'Mengambil data dari database...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    if (grafikState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                grafikState.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref.read(grafikProvider.notifier).fetchGrafikData(grafikState.period),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                label: const Text('Coba Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bgDark,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = grafikState.data;
    if (data.entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '📊',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Cukup Data',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Isi kuesioner terlebih dahulu untuk melihat analisis grafik perkembanganmu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const KuesionerScreen()),
                  );
                },
                icon: const Icon(Icons.assignment_outlined, color: Colors.white, size: 18),
                label: const Text(
                  'Isi Kuesioner',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // 1. Trend Skor Dependensi
        _card(
          title: 'Trend Skor Dependensi',
          subtitle: 'Analisis tingkat ketergantungan digital',
          child: SimpleLineChart(
            values: data.dependenceValues,
            labels: data.labels,
            color: AppColors.teal,
            maxValue: 100,
          ),
        ),
        const SizedBox(height: 20),

        // 2. Rata-rata Screen Time
        _card(
          title: 'Rata-rata Screen Time',
          subtitle: 'Durasi penggunaan perangkat dalam jam/hari',
          child: SimpleLineChart(
            values: data.deviceHourValues,
            labels: data.labels,
            color: AppColors.blue,
            maxValue: 15,
          ),
        ),
        const SizedBox(height: 20),

        // 3. Media Sosial
        _card(
          title: 'Media Sosial',
          subtitle: 'Menit yang dihabiskan untuk hiburan & sosial',
          child: GenericBarChart(
            values: data.socialMediaValues,
            labels: data.labels,
            color: AppColors.purple,
            maxValue: 500,
          ),
        ),
        const SizedBox(height: 20),

        // 4. Kualitas Tidur
        _card(
          title: 'Kualitas Tidur',
          subtitle: 'Durasi istirahat malam (jam tidur)',
          child: GenericBarChart(
            values: data.sleepHourValues,
            labels: data.labels,
            color: Colors.indigo,
            maxValue: 12,
          ),
        ),
      ],
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 3) return;
    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const KuesionerScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPerkembanganScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilScreen()),
        );
        break;
    }
  }

  Widget _buildHeroHeader() {
    return Stack(
      children: [
        // ── Background gelap beserta konten header ─────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 72),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bgDark,
                AppColors.bgDark.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: Row(
            children: [
              // Header icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.teal.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.teal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visualisasi Data',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Analisis aktivitas digital harianmu',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Floating particles ──
        const Positioned.fill(
          child: FloatingParticles(count: 12, color: AppColors.teal),
        ),

        // ── Wave putih melengkung ke atas — unified _WaveClipper ───────
        Positioned(
          left: 0,
          right: 0,
          bottom: -1,
          child: ClipPath(
            clipper: _WaveClipper(),
            child: Container(height: 60, color: _kIce),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(int selectedIndex) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          _periodLabels.length,
          (i) => _buildPeriodItem(i, selectedIndex),
        ),
      ),
    );
  }

  Widget _buildPeriodItem(int i, int selectedIndex) {
    final isSelected = selectedIndex == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(grafikProvider.notifier).setPeriod(_periodMap[i]),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.bgDark : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.bgDark.withValues(alpha: 0.2)
                    : AppColors.bgDark.withValues(alpha: 0.0),
                blurRadius: 8,
                offset: isSelected ? const Offset(0, 2) : Offset.zero,
              ),
            ],
          ),
          child: Text(
            _periodLabels[i],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}