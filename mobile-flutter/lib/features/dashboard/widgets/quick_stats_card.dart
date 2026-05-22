import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuickStatsGrid extends StatelessWidget {
  final double screenTime;
  final double sleepDuration;

  /// Jika false, tampilkan "belum cukup data" state
  final bool hasWeeklyData;

  /// Jumlah data yang sudah diisi (untuk progress bar, maks 7)
  final int dataCount;

  const QuickStatsGrid({
    super.key,
    this.screenTime = 0.0,
    this.sleepDuration = 0.0,
    this.hasWeeklyData = false,
    this.dataCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasWeeklyData) {
      return _buildUnlockCard();
    }

    return Row(
      children: [
        // Screen Time Card
        Expanded(
          child: _StatCard(
            icon: Icons.smartphone_rounded,
            iconColor: AppColors.amber,
            iconBgColor: AppColors.amber.withValues(alpha: 0.2),
            gradientStart: AppColors.amber.withValues(alpha: 0.1),
            gradientEnd: Colors.white,
            borderColor: AppColors.amber.withValues(alpha: 0.2),
            label: 'Screen Time',
            value: screenTime,
            unit: 'Jam',
            sublabel: 'Rata-rata 7 hari',
          ),
        ),
        const SizedBox(width: 12),
        // Sleep Duration Card
        Expanded(
          child: _StatCard(
            icon: Icons.nightlight_round,
            iconColor: AppColors.blue,
            iconBgColor: AppColors.blue.withValues(alpha: 0.2),
            gradientStart: AppColors.blue.withValues(alpha: 0.1),
            gradientEnd: Colors.white,
            borderColor: AppColors.blue.withValues(alpha: 0.2),
            label: 'Durasi Tidur',
            value: sleepDuration,
            unit: 'Jam',
            sublabel: 'Rata-rata 7 hari',
          ),
        ),
      ],
    );
  }

  /// Card menarik yang menampilkan progress menuju 7 pengisian
  Widget _buildUnlockCard() {
    final progress = (dataCount / 7).clamp(0.0, 1.0);
    final remaining = 7 - dataCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.teal.withValues(alpha: 0.08),
            AppColors.blue.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: AppColors.teal.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Ikon kiri ────────────────────────────────────────────────
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.teal, AppColors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.bar_chart_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // ── Teks + Progress ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistik Mingguan',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  remaining == 0
                      ? 'Sedang memproses data...'
                      : 'Isi $remaining pengisian lagi untuk membuka',
                  style: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.teal.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                  ),
                ),
                const SizedBox(height: 6),

                // Label progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(7, (i) {
                        final filled = i < dataCount;
                        return Container(
                          margin: const EdgeInsets.only(right: 3),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? AppColors.teal
                                : AppColors.teal.withValues(alpha: 0.18),
                          ),
                        );
                      }),
                    ),
                    Text(
                      '$dataCount / 7',
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color gradientStart;
  final Color gradientEnd;
  final Color borderColor;
  final String label;
  final double value;
  final String unit;
  final String? sublabel;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.borderColor,
    required this.label,
    required this.value,
    required this.unit,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Blur decoration
          Positioned(
            top: -16,
            right: -16,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (sublabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  sublabel!,
                  style: TextStyle(
                    color: iconColor.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
