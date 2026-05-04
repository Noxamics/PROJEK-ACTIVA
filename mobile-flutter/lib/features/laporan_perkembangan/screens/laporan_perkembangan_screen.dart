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
                        top: Radius.circular(24),
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
              const Icon(Icons.error_outline, color: AppColors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    ref.read(laporanProvider.notifier).fetchLaporan(),
                child: const Text(
                  'Coba lagi',
                  style: TextStyle(color: AppColors.teal),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = state.data;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ① Status Banner
          _buildStatusBanner(data),
          const SizedBox(height: 24),

          // ② Insight Utama
          _sectionLabel('INSIGHT UTAMA'),
          const SizedBox(height: 12),
          _buildInsightCards(data),
          const SizedBox(height: 24),

          // ③ Bar Chart Perbandingan
          _sectionLabel('PERBANDINGAN SKOR'),
          const SizedBox(height: 12),
          _buildComparisonChart(data),
          const SizedBox(height: 24),

          // ④ Penyebab
          _sectionLabel('PENYEBAB UTAMA'),
          const SizedBox(height: 12),
          _buildTagsCard(
            data?.causes ?? [],
            icon: Icons.warning_amber_rounded,
            color: AppColors.red,
          ),
          const SizedBox(height: 16),

          // ⑤ Rekomendasi
          _sectionLabel('REKOMENDASI AI'),
          const SizedBox(height: 12),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Perkembangan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                '14 data terakhir = ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
        ? 'Kondisi Membaik'
        : isMemburuk
        ? 'Kondisi Memburuk'
        : 'Kondisi Stabil';
    final absPct = data.scorePct.abs().toStringAsFixed(1);
    final subtitle = isMembaik
        ? 'Skor turun $absPct% dari periode sebelumnya'
        : isMemburuk
        ? 'Skor naik $absPct% dari periode sebelumnya'
        : 'Perubahan skor < 2% dari periode sebelumnya';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 13,
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
          title: 'Digital Dependence Score',
          desc: insights?.digitalDependence ?? 'Memuat data...',
        ),
        _insightItem(
          icon: Icons.timer_rounded,
          color: AppColors.blue,
          title: 'Screen Time',
          desc: insights?.screenTime ?? 'Memuat data...',
        ),
        _insightItem(
          icon: Icons.share_rounded,
          color: AppColors.purple,
          title: 'Social Media Usage',
          desc: insights?.socialMedia ?? 'Memuat data...',
        ),
        _insightItem(
          icon: Icons.bedtime_rounded,
          color: Colors.indigo,
          title: 'Sleep',
          desc: insights?.sleep ?? 'Memuat data...',
        ),
        _insightItem(
          icon: Icons.psychology_rounded,
          color: AppColors.amber,
          title: 'Stress Level',
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textDark,
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

  // ── Comparison Chart ───────────────────────────────────────────────────────

  Widget _buildComparisonChart(LaporanModel? data) {
    final thisScore = data?.thisWeekAvg ?? 0;
    final lastScore = data?.lastWeekAvg ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _chartBar('7 Data Lalu', lastScore, Colors.grey.shade400),
              const SizedBox(width: 40),
              _chartBar('7 Data Ini', thisScore, AppColors.teal),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          const Text(
            'Rata-rata Digital Dependence Score',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: 120,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: (value / 100).clamp(0.05, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 11,
            fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: items.isEmpty
          ? const Text(
              'Belum ada data.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.teal,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Saran untuk kamu',
                style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Text(
              'Belum ada rekomendasi.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.teal,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          height: 1.5,
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

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    ),
  );

  // ── Lock Overlay (tidak diubah, sudah OK) ──────────────────────────────────

  Widget _buildLockOverlay(int currentCount) {
    final remaining = 14 - currentCount;
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.white.withValues(alpha: 0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: AppColors.teal,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Fitur Terkunci',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Isi kuesioner $remaining x lagi untuk membuka fitur ini',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDark.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (currentCount / 14).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$currentCount / 14 Kuesioner',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
