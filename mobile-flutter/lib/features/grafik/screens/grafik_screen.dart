import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../profil/screens/profil_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../widgets/v2_charts.dart';

class GrafikScreen extends ConsumerStatefulWidget {
  const GrafikScreen({super.key});

  @override
  ConsumerState<GrafikScreen> createState() => _GrafikScreenState();
}

class _GrafikScreenState extends ConsumerState<GrafikScreen> {
  int _selectedPeriod = 0; // 0=7Hari, 1=Bulanan, 2=3Bulan
  static const _periods = ['7 Hari', 'Bulanan', '3 Bulan'];

  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardProvider);
    final analytics = dashState.analytics;

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
                child: analytics == null && dashState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.teal),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                        child: Column(
                          children: [
                            _buildPeriodSelector(),
                            const SizedBox(height: 32),

                            // 1. Digital Dependence Trend (Line Chart)
                            _card(
                              title: 'Trend Skor Dependensi',
                              subtitle: 'Analisis harian tingkat ketergantungan digital',
                              child: SimpleLineChart(
                                values:
                                    analytics?.dailyTrend
                                        .map((t) => t.dependenceScore)
                                        .toList() ??
                                    [],
                                labels:
                                    analytics?.dailyTrend
                                        .map((t) => t.shortDate)
                                        .toList() ??
                                    [],
                                color: AppColors.teal,
                                maxValue: 100,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 2. Screen Time Trend (Line Chart)
                            _card(
                              title: 'Rata-rata Screen Time',
                              subtitle: 'Durasi penggunaan perangkat dalam jam/hari',
                              child: SimpleLineChart(
                                values:
                                    analytics?.dailyTrend
                                        .map((t) => t.deviceHours)
                                        .toList() ??
                                    [],
                                labels:
                                    analytics?.dailyTrend
                                        .map((t) => t.shortDate)
                                        .toList() ??
                                    [],
                                color: AppColors.blue,
                                maxValue: 15,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 3. Social Media Usage (Bar Chart)
                            _card(
                              title: 'Media Sosial',
                              subtitle: 'Menit yang dihabiskan untuk hiburan & sosial',
                              child: GenericBarChart(
                                values:
                                    analytics?.dailyTrend
                                        .map(
                                          (t) => t.socialMediaMins.toDouble(),
                                        )
                                        .toList() ??
                                    [],
                                labels:
                                    analytics?.dailyTrend
                                        .map((t) => t.shortDate)
                                        .toList() ??
                                    [],
                                color: AppColors.purple,
                                maxValue: 500,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 4. Sleep Tracking (Bar Chart)
                            _card(
                              title: 'Kualitas Tidur',
                              subtitle: 'Durasi istirahat malam (jam tidur)',
                              child: GenericBarChart(
                                values:
                                    analytics?.dailyTrend
                                        .map((t) => t.sleepHours)
                                        .toList() ??
                                    [],
                                labels:
                                    analytics?.dailyTrend
                                        .map((t) => t.shortDate)
                                        .toList() ??
                                    [],
                                color: Colors.indigo,
                                maxValue: 12,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 5. Category Donut Chart
                            _card(
                              title: 'Kategori Dependensi',
                              subtitle: 'Distribusi tingkat dependensi selama periode ini',
                              child: DonutChartWidget(
                                low: analytics?.countLow ?? 0,
                                medium: analytics?.countMedium ?? 0,
                                high: analytics?.countHigh ?? 0,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
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

  Widget _buildPeriodSelector() {
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
        children: List.generate(_periods.length, (i) => _buildPeriodItem(i)),
      ),
    );
  }

  Widget _buildPeriodItem(int i) {
    final isSelected = _selectedPeriod == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.bgDark : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.bgDark.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            _periods[i],
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

  Widget _card({required String title, String? subtitle, required Widget child}) {
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
