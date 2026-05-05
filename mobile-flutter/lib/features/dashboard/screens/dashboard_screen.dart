import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import 'dart:ui';
import '../widgets/score_card.dart';
import '../../histori/providers/histori_provider.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../profil/screens/profil_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardProvider);
    final user = ref.watch(currentUserProvider);
    final analytics = dashState.analytics;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(user),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: RefreshIndicator(
                  color: AppColors.teal,
                  onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
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
                          _buildScoreCards(ref),
                          const SizedBox(height: 24),
                          _buildInsightCard(analytics),
                          const SizedBox(height: 24),
                          _buildQuickInfo(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            BottomNav(
              currentIndex: 0,
              navTheme: NavTheme.light,
              onTap: (i) => _onNavTap(context, i),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
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

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(user) {
    final name = user?.name ?? 'Pengguna';
    final initials = user?.initials ?? '?';

    // Greeting berdasarkan jam
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Selamat pagi,'
        : hour < 15
        ? 'Selamat siang,'
        : hour < 18
        ? 'Selamat sore,'
        : 'Selamat malam,';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.3), width: 2),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.teal,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Score Cards ────────────────────────────────────────────────────────────

  Widget _buildScoreCards(WidgetRef ref) {
    final historiState = ref.watch(historiProvider);
    final hasData = historiState.items.isNotEmpty;
    final value = hasData ? historiState.items.first.digitalDependenceScore.round().toString() : '0';

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            ScoreCard(
              label: 'Skor Dependensi', 
              value: value, 
              color: hasData ? AppColors.red : AppColors.textMuted,
            ),
          ],
        ),
        if (!hasData)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: AppColors.bgDark.withValues(alpha: 0.4),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white, size: 28),
                      SizedBox(height: 10),
                      Text(
                        'Silakan isi kuesioner\nuntuk melihat skor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Insight Card ───────────────────────────────────────────────────────────

  Widget _buildInsightCard(analytics) {
    final insightText =
        analytics?.insightText ??
        'Isi kuesioner untuk melihat insight pertamamu.';
    final changeLabel = analytics?.dependenceChangeLabelFormatted ?? '';
    final isPositive = (analytics?.dependenceChangePercentage ?? 0) < 0;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.blue, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Insight Minggu Ini',
                style: TextStyle(
                  color: AppColors.textMuted, 
                  fontSize: 13, 
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            insightText,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          if (changeLabel.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildChangeBadge(changeLabel, isPositive),
          ],
        ],
      ),
    );
  }

  Widget _buildChangeBadge(String label, bool isPositive) {
    final color = isPositive ? AppColors.teal : AppColors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_down_rounded : Icons.trending_up_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            'Dependensi $label minggu ini',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.teal.withValues(alpha: 0.1), AppColors.teal.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: AppColors.teal, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Tips: Coba kurangi penggunaan gadget 1 jam sebelum tidur untuk kualitas istirahat lebih baik.',
              style: TextStyle(
                color: AppColors.textDark.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading Shimmer ────────────────────────────────────────────────────────

  Widget _buildLoadingShimmer() {
    return Column(
      children: [
        Row(
          children: List.generate(
            2,
            (_) => Expanded(
              child: Container(
                height: 140,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ],
    );
  }
}
