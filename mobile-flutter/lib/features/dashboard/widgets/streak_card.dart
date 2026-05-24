import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;
  final int lastFilledDaysAgo;
  final String? subtitle;

  const StreakCard({
    super.key,
    required this.streakDays,
    this.lastFilledDaysAgo = -1,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final hasStreak = streakDays > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: hasStreak ? _buildActiveStreak() : _buildInactiveStreak(),
    );
  }

  // ── Active streak: 🔥 X Hari Konsisten ──────────────────────────────────
  Widget _buildActiveStreak() {
    final displaySubtitle =
        subtitle ?? 'Kamu rutin memantau kesehatan digitalmu';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Text(
              '$streakDays Hari Konsisten',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            '"$displaySubtitle"',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ── Inactive streak: 📅 Terakhir isi: X hari lalu ──────────────────────
  Widget _buildInactiveStreak() {
    final String label;
    if (lastFilledDaysAgo < 0) {
      label = 'Belum pernah mengisi kuesioner';
    } else if (lastFilledDaysAgo == 0) {
      label = 'Terakhir mengisi kuesioner: hari ini';
    } else {
      label = 'Terakhir mengisi kuesioner: $lastFilledDaysAgo hari lalu';
    }

    return Row(
      children: [
        const Text('📅', style: TextStyle(fontSize: 26)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}
