// lib/features/grafik/screens/grafik_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../profil/screens/profil_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../faker/grafik_faker.dart';
import '../providers/grafik_provider.dart';
import '../widgets/v2_charts.dart';

class GrafikScreen extends ConsumerStatefulWidget {
  const GrafikScreen({super.key});

  @override
  ConsumerState<GrafikScreen> createState() => _GrafikScreenState();
}

class _GrafikScreenState extends ConsumerState<GrafikScreen> {
  static const _periods = GrafikPeriod.values;

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(grafikProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: asyncState.when(
                  loading: () => _buildLoading(),
                  error:   (e, _) => _buildError(e.toString()),
                  data:    (grafikState) => _buildContent(grafikState),
                ),
              ),
            ),
            BottomNav(
              currentIndex: 3,
              navTheme: NavTheme.light,
              onTap: (i) => _onNavTap(context, i),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5),
          SizedBox(height: 16),
          Text(
            'Memuat data grafik...',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(grafikProvider.notifier)
                  .setPeriod(ref.read(grafikProvider).value?.period ?? GrafikPeriod.week),
              icon:  const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────

  Widget _buildContent(GrafikState grafikState) {
    final data = grafikState.data;
    final selectedPeriodIndex = _periods.indexOf(grafikState.period);

    // Belum ada data sama sekali (user belum pernah isi kuesioner)
    if (data == null || data.isEmpty) {
      return _buildEmpty(grafikState.period, selectedPeriodIndex);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          _buildPeriodSelector(selectedPeriodIndex),
          const SizedBox(height: 32),

          // 1. Trend Skor Dependensi
          _card(
            title:    'Trend Skor Dependensi',
            subtitle: 'Analisis tingkat ketergantungan digital',
            child: SimpleLineChart(
              values:   data.dependenceValues,
              labels:   data.labels,
              color:    AppColors.teal,
              maxValue: 100,
            ),
          ),
          const SizedBox(height: 20),

          // 2. Rata-rata Screen Time
          _card(
            title:    'Rata-rata Screen Time',
            subtitle: 'Durasi penggunaan perangkat dalam jam/hari',
            child: SimpleLineChart(
              values:   data.deviceHourValues,
              labels:   data.labels,
              color:    AppColors.blue,
              maxValue: 15,
            ),
          ),
          const SizedBox(height: 20),

          // 3. Media Sosial
          _card(
            title:    'Media Sosial',
            subtitle: 'Menit yang dihabiskan untuk hiburan & sosial',
            child: GenericBarChart(
              values:   data.socialMediaValues,
              labels:   data.labels,
              color:    AppColors.purple,
              maxValue: 500,
            ),
          ),
          const SizedBox(height: 20),

          // 4. Kualitas Tidur
          _card(
            title:    'Kualitas Tidur',
            subtitle: 'Durasi istirahat malam (jam tidur)',
            child: GenericBarChart(
              values:   data.sleepHourValues,
              labels:   data.labels,
              color:    Colors.indigo,
              maxValue: 12,
            ),
          ),
          const SizedBox(height: 20),

          // 5. Kategori Dependensi
          _card(
            title:    'Kategori Dependensi',
            subtitle: 'Distribusi tingkat dependensi selama periode ini',
            child: DonutChartWidget(
              low:    data.kategori.low,
              medium: data.kategori.medium,
              high:   data.kategori.high,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmpty(GrafikPeriod period, int selectedPeriodIndex) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          _buildPeriodSelector(selectedPeriodIndex),
          const SizedBox(height: 80),
          const Icon(Icons.bar_chart_rounded, color: AppColors.textMuted, size: 64),
          const SizedBox(height: 20),
          const Text(
            'Belum ada data',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Isi kuesioner harian untuk mulai\nmelihat grafik perkembanganmu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── Nav ───────────────────────────────────────────────────────────────────

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

  // ── UI Helpers ────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visualisasi Data',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Analisis aktivitas digital harianmu',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
          _periods.length,
          (i) => _buildPeriodItem(i, selectedIndex),
        ),
      ),
    );
  }

  Widget _buildPeriodItem(int i, int selectedIndex) {
    final isSelected = selectedIndex == i;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            ref.read(grafikProvider.notifier).setPeriod(_periods[i]);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.bgDark : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.bgDark.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            _periods[i].label,
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