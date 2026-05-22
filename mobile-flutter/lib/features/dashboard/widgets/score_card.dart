import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';

class DependencyScoreCard extends StatelessWidget {
  final int score;
  final int maxScore;
  final String? insight;

  const DependencyScoreCard({
    super.key,
    required this.score,
    this.maxScore = 100,
    this.insight,
  });

  Color get _categoryColor {
    if (score <= 33) return AppColors.teal;
    if (score <= 66) return AppColors.amber;
    return AppColors.red;
  }

  String get _categoryText {
    if (score <= 33) return 'Rendah';
    if (score <= 66) return 'Sedang';
    return 'Tinggi';
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (score / maxScore).clamp(0.0, 1.0);
    final displayColor = _categoryColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bgLight,
            Colors.white,
            AppColors.teal.withValues(alpha: 0.08),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Floating decorations
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blue.withValues(alpha: 0.1),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skor Dependensi',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8,
                          left: 4,
                        ),
                        child: Text(
                          '/ $maxScore',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _categoryText,
                    style: TextStyle(
                      color: displayColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.only(right: 120),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppColors.bgLight.withValues(
                          alpha: 0.5,
                        ),
                        valueColor: AlwaysStoppedAnimation(displayColor),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Mascot Image
            Positioned(
              right: -10,
              bottom: -10,
              child: Image.asset(
                'assets/images/maskot.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
