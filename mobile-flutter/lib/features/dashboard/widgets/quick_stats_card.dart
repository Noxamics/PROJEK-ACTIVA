import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuickStatsGrid extends StatelessWidget {
  final double screenTime;
  final double sleepDuration;

  const QuickStatsGrid({
    super.key,
    this.screenTime = 8.2,
    this.sleepDuration = 5.4,
  });

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
      ],
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
            ],
          ),
        ],
      ),
    );
  }
}
