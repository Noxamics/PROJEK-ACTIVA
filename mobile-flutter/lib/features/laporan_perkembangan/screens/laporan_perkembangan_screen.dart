import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../providers/laporan_provider.dart';
import '../models/laporan_model.dart';
import '../../histori/providers/histori_provider.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../profil/screens/profil_screen.dart';
import '../../grafik/screens/grafik_screen.dart';

class LaporanPerkembanganScreen extends ConsumerStatefulWidget {
  const LaporanPerkembanganScreen({super.key});

  @override
  ConsumerState<LaporanPerkembanganScreen> createState() =>
      _LaporanPerkembanganScreenState();
}

class _LaporanPerkembanganScreenState
    extends ConsumerState<LaporanPerkembanganScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch hanya jika sudah 14 data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final count = ref.read(historiProvider).items.length;
      if (count >= 14) {
        ref.read(laporanProvider.notifier).fetchLaporan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final historiState = ref.watch(historiProvider);
    final historyCount = historiState.items.length;
    final isLocked = historyCount < 14;

    final laporanState = ref.watch(laporanProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(laporanState.data),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: _buildBody(laporanState),
                  ),
                  if (isLocked) _buildLockOverlay(historyCount),
                ],
              ),
            ),
            BottomNav(
              currentIndex: 2,
              navTheme: NavTheme.light,
              onTap: (i) => _onNavTap(context, i),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(LaporanState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }
    if (state.error != null && state.error != 'insufficient_data') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 56),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(laporanProvider.notifier).fetchLaporan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Coba lagi', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final data = state.data;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ① Status Banner
          _buildStatusBanner(data),
          const SizedBox(height: 32),

          // ② Insight Utama
          _sectionLabel('INSIGHT UTAMA'),
          const SizedBox(height: 16),
          _buildInsightCards(data),
          const SizedBox(height: 32),

          // ③ Bar Chart Perbandingan
          _sectionLabel('PERBANDINGAN SKOR'),
          const SizedBox(height: 16),
          _buildComparisonChart(data),
          const SizedBox(height: 32),

          // ④ Penyebab
          _sectionLabel('PENYEBAB UTAMA'),
          const SizedBox(height: 16),
          _buildTagsCard(
            data?.causes ?? [],
            icon: Icons.warning_amber_rounded,
            color: AppColors.red,
          ),
          const SizedBox(height: 32),

          // ⑤ Rekomendasi
          _sectionLabel('REKOMENDASI AI'),
          const SizedBox(height: 16),
          _buildRekomendasiCard(data?.recommendations ?? []),
        ],
      ),
    );
  }

  // ── Header (bgDark) ────────────────────────────────────────────────────────

  Widget _buildHeader(LaporanModel? data) {
    String statusText = '—';
    Color statusColor = AppColors.textSecondary;

    if (data != null) {
      statusText = data.status.toUpperCase();
      statusColor = data.status == 'membaik'
          ? AppColors.teal
          : data.status == 'memburuk'
          ? AppColors.red
          : AppColors.amber;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Analisis',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Trend 14 data terakhir: ',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Banner ──────────────────────────────────────────────────────────

  Widget _buildStatusBanner(LaporanModel? data) {
    if (data == null) return const SizedBox();

    final isMembaik = data.status == 'membaik';
    final isMemburuk = data.status == 'memburuk';
    final color = isMembaik
        ? AppColors.teal
        : isMemburuk
        ? AppColors.red
        : AppColors.amber;
    final icon = isMembaik
        ? Icons.trending_up_rounded
        : isMemburuk
        ? Icons.trending_down_rounded
        : Icons.trending_flat_rounded;
    final label = isMembaik
        ? 'Trend Membaik'
        : isMemburuk
        ? 'Trend Memburuk'
        : 'Trend Stabil';
    final absPct = data.scorePct.abs().toStringAsFixed(1);
    final subtitle = isMembaik
        ? 'Skor turun $absPct% dari periode sebelumnya'
        : isMemburuk
        ? 'Skor naik $absPct% dari periode sebelumnya'
        : 'Perubahan skor < 2% (relatif stabil)';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Insight Cards ──────────────────────────────────────────────────────────

  Widget _buildInsightCards(LaporanModel? data) {
    final insights = data?.insights;
    return Column(
      children: [
        _insightItem(
          icon: Icons.speed_rounded,
          color: AppColors.teal,
          title: 'Skor Dependensi',
          desc: insights?.digitalDependence ?? 'Memuat data...',
        ),
        _insightItem(
          icon: Icons.timer_rounded,
          color: AppColors.blue,
          title: 'Waktu Layar',
          desc: insights?.screenTime ?? 'Memuat data...',
        ),
        _insightItem(
          icon: Icons.share_rounded,
          color: AppColors.purple,
          title: 'Media Sosial',
          desc: insights?.socialMedia ?? 'Memuat data...',
        ),
        _insightItem(
          icon: Icons.bedtime_rounded,
          color: Colors.indigo,
          title: 'Kualitas Tidur',
          desc: insights?.sleep ?? 'Memuat data...',
        ),
        _insightItem(
          icon: Icons.psychology_rounded,
          color: AppColors.amber,
          title: 'Tingkat Stres',
          desc: insights?.stress ?? 'Memuat data...',
        ),
      ],
    );
  }

  Widget _insightItem({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Comparison Chart ───────────────────────────────────────────────────────

  Widget _buildComparisonChart(LaporanModel? data) {
    final thisScore = data?.thisWeekAvg ?? 0;
    final lastScore = data?.lastWeekAvg ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _chartBar('7 Data Lalu', lastScore, Colors.grey.shade300),
              _chartBar('7 Data Ini', thisScore, AppColors.teal),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Rata-rata Digital Dependence Score',
              style: TextStyle(
                color: AppColors.textMuted, 
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartBar(String label, double value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: color == Colors.grey.shade300 ? AppColors.textMuted : color,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 140,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              width: 64,
              height: 140 * (value / 100).clamp(0.05, 1.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── Tags / Penyebab Card ───────────────────────────────────────────────────

  Widget _buildTagsCard(
    List<String> items, {
    required IconData icon,
    required Color color,
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: items.isEmpty
          ? const Text(
              'Belum ada data pemicu terdeteksi.',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            )
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tag_rounded, color: color, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            tag,
                            style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  // ── Rekomendasi Card ───────────────────────────────────────────────────────

  Widget _buildRekomendasiCard(List<String> items) {
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.teal, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Saran Perbaikan AI',
                style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (items.isEmpty)
            const Text(
              'Belum ada rekomendasi khusus saat ini.',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    ),
  );

  // ── Lock Overlay ───────────────────────────────────────────────────────────

  Widget _buildLockOverlay(int currentCount) {
    final remaining = 14 - currentCount;
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.white.withValues(alpha: 0.4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: AppColors.teal,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Analisis Terkunci',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'Kami butuh $remaining data harian lagi untuk memberikan analisis perkembangan yang akurat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDark.withValues(alpha: 0.7),
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 240,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (currentCount / 14).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.tealLight, AppColors.teal],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.teal.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$currentCount / 14 Data Terkumpul',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 2) return;
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
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GrafikScreen()),
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
}
