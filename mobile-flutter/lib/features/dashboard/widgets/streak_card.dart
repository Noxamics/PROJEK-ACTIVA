import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;
  final String? subtitle;

  const StreakCard({super.key, required this.streakDays, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final displaySubtitle =
        subtitle ??
        (streakDays > 0
            ? 'Kebiasaan sehatmu mulai terbentuk.'
            : 'Mulai kebiasaan sehatmu!');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.teal, AppColors.teal.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Floating decoration
          Positioned(
            top: -16,
            right: -16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Row(
            children: [
              // Fire icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.amber,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streakDays Hari Streak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displaySubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Streak flames
              Row(
                children: List.generate(
                  streakDays.clamp(0, 5),
                  (i) => Transform.translate(
                    offset: Offset(-i * 4.0, i % 2 == 0 ? -2 : 2),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.amber.withValues(
                          alpha: 0.8 - (i * 0.15),
                        ),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
