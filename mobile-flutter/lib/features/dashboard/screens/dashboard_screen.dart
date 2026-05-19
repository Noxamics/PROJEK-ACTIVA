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
import '../models/analytics_model.dart';
import '../../laporan_perkembangan/models/laporan_model.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../profil/screens/profil_screen.dart';

// Warna background konten (putih/light) — dipakai oleh wave clipper
const Color _kIce = AppColors.bgLight;

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentNavIndex = 0;

  // Habit tracker state — "Tidur sebelum 23.00" diganti "Tidur melebihi 7-8 jam"
  List<HabitItem> _habits = [
    const HabitItem(id: '1', label: 'Tidur melebihi 7-8 jam', completed: true),
    const HabitItem(id: '2', label: 'Screen time < 6 jam', completed: true),
    const HabitItem(id: '3', label: 'Istirahat media sosial', completed: false),
    const HabitItem(id: '4', label: 'Aktivitas fisik', completed: true),
  ];

  void _toggleHabit(String id) {
    setState(() {
      _habits = _habits.map((h) {
        if (h.id == id) {
          return h.copyWith(completed: !h.completed);
        }
        return h;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardProvider);
    final user = ref.watch(currentUserProvider);
    final analytics = dashState.analytics;

    final historiCount = ref.watch(historiProvider).items.length;
    final laporanState = ref.watch(laporanProvider);

    // Auto-fetch laporan jika data cukup
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
            _HeroHeader(
              user: user,
              greeting: _getGreeting(),
            ),

            // ── Main Content ─────────────────────────────────────────────
            Expanded(
              child: Container(
                color: AppColors.bgLight, // lanjutan warna wave
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
                        // Loading state
                        if (dashState.isLoading && analytics == null)
                          _buildLoadingShimmer()
                        else ...[
                          // 1. Dependency Score Card
                          DependencyScoreCard(
                            score: analytics?.avgDependenceInt ?? 72,
                            insight:
                                'Screen time malam kamu meningkat minggu ini.',
                          ),
                          const SizedBox(height: 16),

                          // 2. Quick Stats (Screen Time & Sleep Duration)
                          QuickStatsGrid(
                            screenTime: analytics?.screenTimeHours ?? 8.2,
                            sleepDuration: analytics?.sleepHours ?? 5.4,
                          ),
                          const SizedBox(height: 16),

                          // 3. Streak Card
                          StreakCard(
                            streakDays: ref.watch(streakProvider).count,
                            subtitle: 'Kebiasaan sehatmu mulai terbentuk.',
                          ),
                          const SizedBox(height: 16),

                          // 4. CTA Button - Isi Kuesioner
                          _buildCTAButton(context),
                          const SizedBox(height: 16),

                          // 5. Weekly Insight Card
                          WeeklyInsightCard(
                            insight:
                                'Ketergantungan digital kamu membaik 8% dibanding minggu lalu.',
                            onViewDetails: () => _showInsightDetail(context),
                          ),
                          const SizedBox(height: 16),

                          // 6. Progress Performance Chart (Donut / Kategori Dependensi)
                          DependencyDonutChart(
                            countLow: analytics?.countLow ?? 2,
                            countMedium: analytics?.countMedium ?? 4,
                            countHigh: analytics?.countHigh ?? 1,
                            totalSurveys: analytics?.totalSurveysWeek ?? 7,
                          ),
                          const SizedBox(height: 16),

                          // 7. Habit Tracker
                          HabitTracker(habits: _habits, onToggle: _toggleHabit),
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

  // ── CTA Button ─────────────────────────────────────────────────────────────

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

  // ── Bottom Sheet — Insight Detail ──────────────────────────────────────────

  void _showInsightDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textDisabled.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Insight Mingguan',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Analisis mingguan menunjukkan:\n\n'
              '- Ketergantungan digital menurun 8%\n'
              '- Screen time rata-rata: 7.5 jam/hari\n'
              '- Waktu tidur membaik 15 menit\n'
              '- Penggunaan sosial media berkurang 12%\n\n'
              'Pertahankan kebiasaan positif ini!',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── Loading Shimmer ────────────────────────────────────────────────────────

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

  // ── Navigation ─────────────────────────────────────────────────────────────

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
          // Extra bottom padding agar konten tidak tertimpa wave
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 52),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.bgDark, AppColors.bgDark.withValues(alpha: 0.95)],
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
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Digital wellness progress',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Bell notifikasi dihapus
            ],
          ),
        ),

        // ── Wave putih melengkung ke atas (bentuk U terbalik) di bawah header ──
        // ClipPath memotong Container putih mengikuti kurva quadraticBezier,
        // sehingga transisi dari header gelap ke konten putih terlihat smooth.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipPath(
            clipper: _BottomWaveClipper(),
            child: Container(height: 40, color: _kIce),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _BottomWaveClipper — Membuat path lengkung seperti huruf U
//
// Cara kerja:
//   - Mulai dari pojok kiri bawah (0, height)
//   - Naik ke pojok kiri atas (0, height * 0.5)
//   - quadraticBezierTo: control point di tengah atas (width*0.5, 0)
//     menuju pojok kanan (width, height*0.5)
//     → inilah yang menciptakan lekukan U menghadap ke atas
//   - Turun kembali ke pojok kanan bawah (width, height)
//   - Tutup path
// ═══════════════════════════════════════════════════════════════════════════

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path();

    // Mulai dari kiri bawah
    p.moveTo(0, s.height);

    // Naik ke kiri atas
    p.lineTo(0, s.height * 0.5);

    // Kurva quadratic: control point di puncak tengah → menuju kanan tengah
    // control point (s.width * 0.5, 0) menarik kurva ke atas → bentuk U
    p.quadraticBezierTo(
      s.width * 0.5, // control x — titik tarikan kurva (tengah)
      0,             // control y — puncak lengkungan (atas)
      s.width,       // end x — ujung kanan
      s.height * 0.5, // end y — kembali ke tengah kanan
    );

    // Turun ke kanan bawah lalu tutup
    p.lineTo(s.width, s.height);
    p.close();

    return p;
  }

  @override
  bool shouldReclip(_BottomWaveClipper oldClipper) => false;
}