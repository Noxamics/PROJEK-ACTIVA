import 'dart:math' as math;
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
import '../../profil/widgets/floating_particles.dart';

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

// ─── Tag translation map ──────────────────────────────────────────────────────

const Map<String, String> _kTagLabels = {
  'screen_time_high': 'Waktu Layar Tinggi',
  'screen time high': 'Waktu Layar Tinggi',
  'notification_overload': 'Notifikasi Berlebihan',
  'notification overload': 'Notifikasi Berlebihan',
  'sleep_low': 'Tidur Kurang',
  'sleep low': 'Tidur Kurang',
  'sleep_bad_quality': 'Kualitas Tidur Buruk',
  'sleep bad quality': 'Kualitas Tidur Buruk',
  'anxiety_high': 'Kecemasan Tinggi',
  'anxiety high': 'Kecemasan Tinggi',
  'depression_high': 'Depresi Tinggi',
  'depression high': 'Depresi Tinggi',
  'stress_high': 'Stres Tinggi',
  'stress high': 'Stres Tinggi',
  'happiness_low': 'Kebahagiaan Rendah',
  'happiness low': 'Kebahagiaan Rendah',
  'general': 'Umum',
};

String _translateTag(String tag) {
  final key = tag.trim().toLowerCase().replaceAll('_', ' ');
  return _kTagLabels[key] ?? tag;
}

IconData _tagIcon(String tag) {
  final key = tag.trim().toLowerCase().replaceAll('_', ' ');
  const map = {
    'screen time high': Icons.phone_android_rounded,
    'notification overload': Icons.notifications_rounded,
    'sleep low': Icons.bedtime_rounded,
    'sleep bad quality': Icons.bedtime_off_rounded,
    'anxiety high': Icons.sentiment_very_dissatisfied_rounded,
    'depression high': Icons.cloud_rounded,
    'stress high': Icons.psychology_rounded,
    'happiness low': Icons.mood_bad_rounded,
    'general': Icons.info_outline_rounded,
  };
  return map[key] ?? Icons.warning_amber_rounded;
}

// ═════════════════════════════════════════════════════════════════════════════
// LaporanPerkembanganScreen
// ═════════════════════════════════════════════════════════════════════════════

class LaporanPerkembanganScreen extends ConsumerStatefulWidget {
  const LaporanPerkembanganScreen({super.key});

  @override
  ConsumerState<LaporanPerkembanganScreen> createState() =>
      _LaporanPerkembanganScreenState();
}

class _LaporanPerkembanganScreenState
    extends ConsumerState<LaporanPerkembanganScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final count = ref.read(historiProvider).items.length;
      if (count >= 14) {
        ref.read(laporanProvider.notifier).fetchLaporan();
      }
      _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
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
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            children: [
              _HeroHeader(laporanData: laporanState.data),
              Expanded(
                child: Container(
                  color: AppColors.bgLight,
                  child: Stack(
                    children: [
                      _buildBody(laporanState),
                      if (isLocked) _LockOverlay(currentCount: historyCount),
                    ],
                  ),
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
      ),
    );
  }

  Widget _buildBody(LaporanState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5),
            SizedBox(height: 20),
            Text(
              'Activa sedang menganalisis\nperjalanan digitalmu...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (state.error != null && state.error != 'insufficient_data') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(laporanProvider.notifier).fetchLaporan(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
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
          _TrendHeroCard(data: data),
          const SizedBox(height: 28),

          _SectionLabel(label: 'ANALISIS AI', icon: Icons.auto_awesome_rounded),
          const SizedBox(height: 14),
          _InsightSection(data: data),
          const SizedBox(height: 28),

          _SectionLabel(
            label: 'PERBANDINGAN SKOR',
            icon: Icons.compare_arrows_rounded,
          ),
          const SizedBox(height: 14),
          _ComparisonCard(data: data),
          const SizedBox(height: 28),

          _SectionLabel(label: 'FAKTOR BERPENGARUH', icon: Icons.radar_rounded),
          const SizedBox(height: 14),
          _CausesCard(causes: data?.causes ?? []),
          const SizedBox(height: 28),

          _SectionLabel(
            label: 'PANDUAN AI',
            icon: Icons.lightbulb_outline_rounded,
          ),
          const SizedBox(height: 14),
          _RecommendationsSection(recommendations: data?.recommendations ?? []),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 2) return;
    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const KuesionerScreen()),
        );
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GrafikScreen()),
        );
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilScreen()),
        );
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _HeroHeader — Unified dengan wave clipper yang sama di semua layar
// ═════════════════════════════════════════════════════════════════════════════

class _HeroHeader extends StatelessWidget {
  final LaporanModel? laporanData;
  const _HeroHeader({required this.laporanData});

  @override
  Widget build(BuildContext context) {
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
              // Header icon — konsisten dengan kuesioner & dashboard
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
                  Icons.insights_rounded,
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
                      'Laporan Analisis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Perjalanan digital wellness 7 hari terakhir',
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

        // ── Wave putih — unified _WaveClipper ────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: -1,
          child: ClipPath(
            clipper: _WaveClipper(),
            child: Container(height: 60, color: AppColors.bgLight),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Section Label
// ═════════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.teal, size: 14),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _TrendHeroCard — Dark blue background
// ═════════════════════════════════════════════════════════════════════════════

class _TrendHeroCard extends StatelessWidget {
  final LaporanModel? data;
  const _TrendHeroCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final trend = data?.status ?? 'stabil';
    final pct = data?.scorePct.abs().toStringAsFixed(1) ?? '—';

    final Color accentColor = trend == 'membaik'
        ? AppColors.teal
        : trend == 'memburuk'
        ? AppColors.red
        : AppColors.amber;

    final IconData mascotIcon = trend == 'membaik'
        ? Icons.sentiment_satisfied_alt_rounded
        : trend == 'memburuk'
        ? Icons.sentiment_dissatisfied_rounded
        : Icons.sentiment_neutral_rounded;

    final String trendMsg = trend == 'membaik'
        ? 'Kondisi digitalmu membaik $pct% dibanding minggu lalu'
        : trend == 'memburuk'
        ? 'Ketergantungan digital meningkat $pct% dalam 7 hari terakhir'
        : 'Kondisi digitalmu relatif stabil minggu ini';

    final String moodLabel = trend == 'membaik'
        ? 'TREND MEMBAIK'
        : trend == 'memburuk'
        ? 'PERLU PERHATIAN'
        : 'TREND STABIL';

    final IconData trendIcon = trend == 'membaik'
        ? Icons.trending_up_rounded
        : trend == 'memburuk'
        ? Icons.trending_down_rounded
        : Icons.trending_flat_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // ── CHANGED: dark blue gradient background ──
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgDark, AppColors.bgDark.withValues(alpha: 0.88)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.20),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: accentColor.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Icon(mascotIcon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        moodLabel,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // ── CHANGED: white text on dark bg ──
                    Text(
                      'Trend 14 Data Terakhir',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(trendIcon, color: accentColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ── CHANGED: divider color on dark bg ──
          Divider(color: Colors.white.withValues(alpha: 0.10), thickness: 1.5),
          const SizedBox(height: 16),
          // ── CHANGED: white text on dark bg ──
          Text(
            trendMsg,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _MiniBarChart(thisWeek: data?.thisWeekAvg ?? 0, color: accentColor),
        ],
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  final double thisWeek;
  final Color color;
  const _MiniBarChart({required this.thisWeek, required this.color});

  @override
  Widget build(BuildContext context) {
    final bars = [
      0.55,
      0.70,
      0.50,
      0.80,
      0.65,
      0.72,
      (thisWeek / 100).clamp(0.05, 1.0),
    ];
    final maxVal = bars.reduce(math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // ── CHANGED: icon color on dark bg ──
            Icon(
              Icons.bar_chart_rounded,
              color: Colors.white.withValues(alpha: 0.40),
              size: 13,
            ),
            const SizedBox(width: 6),
            Text(
              'Skor 7 Hari Terakhir',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < bars.length; i++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 600 + i * 80),
                  curve: Curves.easeOutCubic,
                  height: 36.0 * (bars[i] / maxVal).clamp(0.1, 1.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: i == bars.length - 1
                          ? [color, color.withValues(alpha: 0.7)]
                          : [
                              color.withValues(alpha: 0.30),
                              color.withValues(alpha: 0.15),
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: i == bars.length - 1
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
              if (i < bars.length - 1) const SizedBox(width: 5),
            ],
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _InsightSection
// ═════════════════════════════════════════════════════════════════════════════

class _InsightSection extends StatelessWidget {
  final LaporanModel? data;
  const _InsightSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final ins = data?.insights;
    final defs = [
      _InsightDef(
        icon: Icons.phone_android_rounded,
        color: AppColors.teal,
        title: 'Screen Time',
        desc: ins?.screenTime ?? 'Menganalisis pola penggunaan layar...',
      ),
      _InsightDef(
        icon: Icons.bedtime_rounded,
        color: AppColors.blue,
        title: 'Kualitas Tidur',
        desc: ins?.sleep ?? 'Menganalisis pola tidur...',
      ),
      _InsightDef(
        icon: Icons.groups_rounded,
        color: AppColors.purple,
        title: 'Media Sosial',
        desc: ins?.socialMedia ?? 'Menganalisis aktivitas media sosial...',
      ),
      _InsightDef(
        icon: Icons.psychology_rounded,
        color: AppColors.amber,
        title: 'Tingkat Stres',
        desc: ins?.stress ?? 'Menganalisis indikator stres...',
      ),
      _InsightDef(
        icon: Icons.bolt_rounded,
        color: AppColors.red,
        title: 'Dependensi Digital',
        desc: ins?.digitalDependence ?? 'Menganalisis dependensi digital...',
      ),
    ];

    return Column(
      children: defs
          .asMap()
          .entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              // ── CHANGED: index 0 & 1 pakai dark style ──
              child: _InsightCard(def: e.value),
            ),
          )
          .toList(),
    );
  }
}

class _InsightDef {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _InsightDef({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });
}

class _InsightCard extends StatelessWidget {
  final _InsightDef def;
  final bool isDark;
  const _InsightCard({required this.def, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ── CHANGED: dark bg ketika isDark ──
        color: isDark ? AppColors.bgDark : AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? def.color.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: isDark
            ? Border.all(color: def.color.withValues(alpha: 0.25))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: def.color.withValues(alpha: isDark ? 0.15 : 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: def.color.withValues(alpha: isDark ? 0.30 : 0.15),
              ),
            ),
            child: Icon(def.icon, color: def.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  def.title.toUpperCase(),
                  style: TextStyle(
                    color: def.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  def.desc,
                  style: TextStyle(
                    // ── CHANGED: teks putih kalau dark ──
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _ComparisonCard
// ═════════════════════════════════════════════════════════════════════════════

class _ComparisonCard extends StatelessWidget {
  final LaporanModel? data;
  const _ComparisonCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final thisScore = data?.thisWeekAvg ?? 0;
    final lastScore = data?.lastWeekAvg ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Bar(
                label: '7 Data Lalu',
                value: lastScore,
                color: AppColors.textDisabled,
              ),
              Container(width: 1, height: 80, color: AppColors.bgLight),
              _Bar(
                label: '7 Data Ini',
                value: thisScore,
                color: AppColors.teal,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, color: AppColors.teal, size: 14),
                const SizedBox(width: 8),
                const Text(
                  'Rata-rata Digital Dependence Score',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _Bar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: color == AppColors.textDisabled
                ? AppColors.textSecondary
                : color,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 68,
          height: 130,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              width: 68,
              height: 130 * (value / 100).clamp(0.05, 1.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _CausesCard
// ═════════════════════════════════════════════════════════════════════════════

class _CausesCard extends StatelessWidget {
  final List<String> causes;
  const _CausesCard({required this.causes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: causes.isEmpty
          ? Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.teal,
                  size: 18,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Tidak ada faktor pemicu yang terdeteksi minggu ini.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: causes.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_tagIcon(tag), color: AppColors.red, size: 14),
                      const SizedBox(width: 7),
                      Text(
                        _translateTag(tag),
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _RecommendationsSection
// ═════════════════════════════════════════════════════════════════════════════

class _RecommendationsSection extends StatelessWidget {
  final List<String> recommendations;
  const _RecommendationsSection({required this.recommendations});

  static const _icons = [
    Icons.nightlight_round,
    Icons.self_improvement_rounded,
    Icons.do_not_disturb_on_rounded,
    Icons.tips_and_updates_rounded,
    Icons.track_changes_rounded,
    Icons.spa_rounded,
    Icons.directions_walk_rounded,
    Icons.menu_book_rounded,
  ];

  static const _colors = [
    AppColors.teal,
    AppColors.blue,
    AppColors.amber,
    AppColors.purple,
    AppColors.red,
    AppColors.teal,
    AppColors.blue,
    AppColors.amber,
  ];

  // ── CHANGED: index 0 pakai dark style di rekomendasi ──
  static const _darkIndices = {0};

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.thumb_up_alt_outlined,
                color: AppColors.teal,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Belum ada panduan khusus. Terus jaga konsistensimu!',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recommendations.asMap().entries.map((e) {
        final idx = e.key;
        final rec = e.value;
        final color = _colors[idx % _colors.length];
        final icon = _icons[idx % _icons.length];
        final isDark = _darkIndices.contains(idx);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // ── CHANGED: dark bg untuk rekomendasi index 0 ──
            color: isDark ? AppColors.bgDark : AppColors.bgWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? color.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? color.withValues(alpha: 0.28)
                  : color.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.15 : 0.10),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: color.withValues(alpha: isDark ? 0.30 : 0.15),
                  ),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    rec,
                    style: TextStyle(
                      // ── CHANGED: teks putih untuk dark card ──
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _LockOverlay
// ═════════════════════════════════════════════════════════════════════════════

class _LockOverlay extends StatelessWidget {
  final int currentCount;
  const _LockOverlay({required this.currentCount});

  @override
  Widget build(BuildContext context) {
    final remaining = 14 - currentCount;
    final progress = (currentCount / 14).clamp(0.0, 1.0);

    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.white.withValues(alpha: 0.55),
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
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: AppColors.teal,
                    size: 44,
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
                    'Activa butuh $remaining data harian lagi untuk memberikan analisis perjalanan digital wellnessmu yang akurat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDark.withValues(alpha: 0.65),
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.data_usage_rounded,
                      color: AppColors.teal,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$currentCount / 14 Data Terkumpul',
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 52),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: LayoutBuilder(
                      builder: (_, c) => Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            width: c.maxWidth * progress,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.tealLight, AppColors.teal],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.teal.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
