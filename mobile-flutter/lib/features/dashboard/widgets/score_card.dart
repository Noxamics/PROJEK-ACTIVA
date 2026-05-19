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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - Score info
                    Expanded(
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
                          ClipRRect(
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
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right side - Circular progress
                    _CircularProgress(
                      percentage: percentage,
                      color: displayColor,
                    ),
                  ],
                ),

                // AI Insight
                if (insight != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.teal.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.teal,
                                AppColors.teal.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight!,
                            style: TextStyle(
                              color: AppColors.textDark.withValues(alpha: 0.8),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final double percentage;
  final Color color;

  const _CircularProgress({required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(112, 112),
            painter: _CircularProgressPainter(
              percentage: percentage,
              color: color,
              backgroundColor: const Color(0xFFE5E7EB),
              strokeWidth: 8,
            ),
          ),
          Center(
            child: Text(
              '${(percentage * 100).round()}%',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
