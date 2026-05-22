import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/score_card.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/habit_tracker.dart';
import '../widgets/weekly_insight_card.dart';
import '../widgets/focus_bar_chart.dart';
import '../../histori/providers/histori_provider.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../../laporan_perkembangan/providers/laporan_provider.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../profil/screens/profil_screen.dart';

// Warna background konten (putih/light) — dipakai oleh wave clipper
const Color _kIce = AppColors.bgLight;

// ══════════════════════════════════════════════════════════════════════════════
// WAVE CLIPPER — Unified, dipakai di semua layar
// Melengkung ke atas di bagian bawah header
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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardProvider);
    final user = ref.watch(currentUserProvider);
    final analytics = dashState.analytics;

    final historiState = ref.watch(historiProvider);
    final historiItems = historiState.items;
    final hasHistory = historiItems.isNotEmpty;
    final latestResult = hasHistory ? historiItems.first : null;
    final historiCount = historiItems.length;

    final laporanState = ref.watch(laporanProvider);

    final weeklyStats = ref.watch(weeklyStatsProvider);
    final hasWeeklyData = ref.watch(hasWeeklyDataProvider);
    final dependencyDistribution = ref.watch(dependencyDistributionProvider);

    if (historiCount >= 14 &&
        laporanState.data == null &&
        !laporanState.isLoading &&
        laporanState.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(laporanProvider.notifier).fetchLaporan();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // ── Hero Header dengan wave putih di bawah ──────────────────
            _HeroHeader(user: user, greeting: _getGreeting()),

            // ── Main Content ─────────────────────────────────────────────
            Expanded(
              child: Container(
                color: AppColors.bgLight,
                child: RefreshIndicator(
                  color: AppColors.teal,
                  onRefresh: () =>
                      ref.read(dashboardProvider.notifier).refresh(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (dashState.isLoading && analytics == null)
                          _buildLoadingShimmer()
                        else ...[
                          Stack(
                            children: [
                              ImageFiltered(
                                imageFilter: !hasHistory
                                    ? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0)
                                    : ImageFilter.blur(
                                        sigmaX: 0.0,
                                        sigmaY: 0.0,
                                      ),
                                child: DependencyScoreCard(
                                  score: latestResult?.dependenceInt ?? 0,
                                  insight:
                                      latestResult?.summary ??
                                      'Silakan isi kuesioner untuk melihat insight kamu.',
                                ),
                              ),
                              if (!hasHistory)
                                Positioned.fill(
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Belum Ada Data',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          QuickStatsGrid(
                            screenTime: weeklyStats.screenTime,
                            sleepDuration: weeklyStats.sleepHours,
                            hasWeeklyData: hasWeeklyData,
                            dataCount: weeklyStats.dataCount,
                          ),
                          const SizedBox(height: 16),

                          StreakCard(
                            streakDays: ref.watch(streakProvider).count,
                            subtitle: 'Kebiasaan sehatmu mulai terbentuk.',
                          ),
                          const SizedBox(height: 16),

                          _buildCTAButton(context),
                          const SizedBox(height: 16),

                          _buildWeeklyInsightCard(context),
                          const SizedBox(height: 16),

                          if (dependencyDistribution.total > 0)
                            DependencyDonutChart(
                              countLow: dependencyDistribution.low,
                              countMedium: dependencyDistribution.medium,
                              countHigh: dependencyDistribution.high,
                              totalSurveys: dependencyDistribution.total,
                            )
                          else
                            const SizedBox(),
                          const SizedBox(height: 16),

                          HabitTracker(
                            habits: [
                              HabitItem(
                                id: '1',
                                label: 'Tidur melebihi 7 jam',
                                completed:
                                    latestResult != null &&
                                    latestResult.sleepHours >= 7,
                              ),
                              HabitItem(
                                id: '2',
                                label: 'Screen time < 6 jam',
                                completed:
                                    latestResult != null &&
                                    latestResult.screenTime > 0 &&
                                    latestResult.screenTime < 6,
                              ),
                              HabitItem(
                                id: '3',
                                label: 'Tingkat Ketergantungan Rendah',
                                completed:
                                    latestResult != null &&
                                    latestResult.digitalDependenceScore < 50,
                              ),
                              HabitItem(
                                id: '4',
                                label: 'Kualitas Tidur Terjaga',
                                completed:
                                    latestResult != null &&
                                    latestResult.sleepHours >= 6 &&
                                    latestResult.sleepHours <= 9,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom Navigation ─────────────────────────────────────────
            BottomNav(
              currentIndex: _currentNavIndex,
              navTheme: NavTheme.light,
              onTap: (i) => _onNavTap(context, i),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Widget _buildCTAButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppColors.bgDark, AppColors.bgDark.withValues(alpha: 0.9)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.bgDark.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KuesionerScreen()),
          ),
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Text(
              'Isi Kuesioner Hari Ini',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyInsightCard(BuildContext context) {
    final laporanState = ref.watch(laporanProvider);
    final data = laporanState.data;

    String insightText;
    if (data != null) {
      final absPct = data.scorePct.abs().toStringAsFixed(1);
      if (data.status == 'membaik') {
        insightText =
            'Ketergantungan digital kamu membaik $absPct% dibanding periode sebelumnya.';
      } else if (data.status == 'memburuk') {
        insightText =
            'Ketergantungan digital kamu meningkat $absPct% dibanding periode sebelumnya.';
      } else {
        insightText =
            'Ketergantungan digital kamu relatif stabil dibanding periode sebelumnya.';
      }
    } else {
      insightText =
          'Isi kuesioner minimal 14 kali untuk melihat insight mingguan.';
    }

    return WeeklyInsightCard(
      insight: insightText,
      onViewDetails: () => _showInsightDetail(context, data),
    );
  }

  void _showInsightDetail(BuildContext context, dynamic data) {
    final List<Map<String, dynamic>> detailItems;
    if (data != null) {
      detailItems = [
        {
          'icon': Icons.speed_rounded,
          'color': AppColors.teal,
          'label': 'Skor Dependensi',
          'value': data.insights.digitalDependence,
        },
        {
          'icon': Icons.timer_rounded,
          'color': AppColors.blue,
          'label': 'Waktu Layar',
          'value': data.insights.screenTime,
        },
        {
          'icon': Icons.share_rounded,
          'color': AppColors.purple,
          'label': 'Media Sosial',
          'value': data.insights.socialMedia,
        },
        {
          'icon': Icons.bedtime_rounded,
          'color': const Color(0xFF6366F1),
          'label': 'Kualitas Tidur',
          'value': data.insights.sleep,
        },
        {
          'icon': Icons.psychology_rounded,
          'color': AppColors.amber,
          'label': 'Tingkat Stres',
          'value': data.insights.stress,
        },
      ];
    } else {
      detailItems = [];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textDisabled.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        color: AppColors.teal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Insight Mingguan',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  children: [
                    if (detailItems.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.bgWhite,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Isi kuesioner minimal 14 kali untuk melihat insight detail mingguan Anda.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...detailItems.map(
                        (item) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.bgWhite,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (item['color'] as Color).withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: item['color'] as Color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['label'] as String,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['value'] as String,
                                      style: const TextStyle(
                                        color: AppColors.textDark,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LaporanPerkembanganScreen(),
                        ),
                      ).then((_) => setState(() => _currentNavIndex = 0));
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Lihat Laporan Lengkap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: [
        _shimmerBox(height: 200),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _shimmerBox(height: 120)),
            const SizedBox(width: 12),
            Expanded(child: _shimmerBox(height: 120)),
          ],
        ),
        const SizedBox(height: 16),
        _shimmerBox(height: 80),
        const SizedBox(height: 16),
        _shimmerBox(height: 56),
        const SizedBox(height: 16),
        _shimmerBox(height: 100),
      ],
    );
  }

  Widget _shimmerBox({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == _currentNavIndex) return;

    setState(() => _currentNavIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KuesionerScreen()),
        ).then((_) => setState(() => _currentNavIndex = 0));
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPerkembanganScreen()),
        ).then((_) => setState(() => _currentNavIndex = 0));
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GrafikScreen()),
        ).then((_) => setState(() => _currentNavIndex = 0));
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilScreen()),
        ).then((_) => setState(() => _currentNavIndex = 0));
        break;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _HeroHeader — Header gelap dengan wave putih melengkung di bagian bawah
// Menggunakan _WaveClipper yang sama dengan semua layar lainnya
// ═══════════════════════════════════════════════════════════════════════════

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.user, required this.greeting});

  final dynamic user;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    final userName = user?.name ?? 'Erick Dwi Kusuma S';
    final initials = userName.isNotEmpty
        ? userName
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : 'U';

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
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.teal, AppColors.blue],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Digital wellness progress',
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
}
