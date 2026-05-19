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
import '../../laporan_perkembangan/providers/laporan_provider.dart';
import '../models/analytics_model.dart';
import '../../laporan_perkembangan/models/laporan_model.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../profil/screens/profil_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardProvider);
    final user = ref.watch(currentUserProvider);
    final analytics = dashState.analytics;
    
    final historiCount = ref.watch(historiProvider).items.length;
    final laporanState = ref.watch(laporanProvider);

    // Auto-fetch laporan jika data cukup
    if (historiCount >= 14 && laporanState.data == null && !laporanState.isLoading && laporanState.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(laporanProvider.notifier).fetchLaporan();
      });
    }

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
                          const SizedBox(height: 16),
                          _buildQuickActions(context, ref),
                          const SizedBox(height: 24),
                          _buildInsightCard(context, analytics, laporanState.data, historiCount),
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
    final category = hasData ? historiState.items.first.category : null;

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            ScoreCard(
              label: 'Skor Dependensi', 
              value: value, 
              category: category,
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

  Widget _buildInsightCard(BuildContext context, AnalyticsModel? analytics, LaporanModel? laporanData, int historiCount) {
    // Prioritaskan insight dari laporan (14 hari) jika tersedia
    final insightText = laporanData?.insights.digitalDependence ?? 
        analytics?.insightText ??
        'Isi kuesioner untuk melihat insight pertamamu.';
    
    final isLocked = historiCount < 14;

    return Stack(
      children: [
        Container(
          width: double.infinity,
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
          child: Tooltip(
            message: isLocked ? 'Kumpulkan 14 data untuk membuka insight' : 'Ketuk untuk detail insight minggu ini',
            decoration: BoxDecoration(
              color: AppColors.bgDark.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(color: Colors.white, fontSize: 12),
            preferBelow: false,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLocked ? null : () => _showInsightPreview(context, analytics, laporanData),
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          const Icon(Icons.info_outline_rounded, color: AppColors.textDisabled, size: 20),
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
                      if (!isLocked) ...[
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Detail Preview',
                            style: TextStyle(
                              color: AppColors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isLocked)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: AppColors.bgWhite.withValues(alpha: 0.7),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_rounded, color: AppColors.blue, size: 24),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Terkunci: $historiCount/14 Kuesioner',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Isi 14 kali untuk melihat analisis trend',
                        style: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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

  void _showInsightPreview(BuildContext context, AnalyticsModel? analytics, LaporanModel? laporanData) {
    final status = laporanData?.status ?? analytics?.dependenceChangeLabel ?? 'Stabil';
    final causes = laporanData?.causes ?? analytics?.causes ?? [];
    final insight = laporanData?.insights.digitalDependence ?? analytics?.insightText ?? '';
    final isPositive = (analytics?.dependenceChangePercentage ?? 0) < 0;

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppColors.teal : AppColors.amber).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPositive ? Icons.check_circle_rounded : Icons.trending_up_rounded,
                    color: isPositive ? AppColors.teal : AppColors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Insight',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Status: $status',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Detail Analisis',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              insight,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (causes.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Faktor Penyebab Utama',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...causes.take(3).map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        c,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LaporanPerkembanganScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bgDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lihat Laporan Lengkap',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }



  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);

    return Column(
      children: [
        // Streak Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  streak.count > 0 ? Icons.local_fire_department_rounded : Icons.calendar_today_rounded,
                  color: AppColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streak.count > 0 ? '${streak.count} Hari Streak' : 'Mulai Kebiasaan',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      streak.message,
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'Isi Kuesioner',
                icon: Icons.assignment_rounded,
                color: AppColors.bgDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KuesionerScreen()),
                ),
              ),
            ),
            // Bisa tambah tombol lain di sini jika perlu
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
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
