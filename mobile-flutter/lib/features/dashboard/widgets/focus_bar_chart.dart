import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ── Donut Chart — Kategori Dependensi ─────────────────────────────────────────

class DependencyDonutChart extends StatelessWidget {
  final int countLow;
  final int countMedium;
  final int countHigh;
  final int totalSurveys;

  const DependencyDonutChart({
    super.key,
    this.countLow = 2,
    this.countMedium = 4,
    this.countHigh = 1,
    this.totalSurveys = 7,
  });

  @override
  Widget build(BuildContext context) {
    final total = countLow + countMedium + countHigh;
    final pctLow = total > 0 ? countLow / total : 0.0;
    final pctMedium = total > 0 ? countMedium / total : 0.0;
    final pctHigh = total > 0 ? countHigh / total : 0.0;

    final segments = [
      _DonutSegment(
        fraction: pctLow,
        color: AppColors.teal,
        label: 'Rendah',
        percentage: '${(pctLow * 100).round()}%',
        count: countLow,
      ),
      _DonutSegment(
        fraction: pctMedium,
        color: AppColors.amber,
        label: 'Sedang',
        percentage: '${(pctMedium * 100).round()}%',
        count: countMedium,
      ),
      _DonutSegment(
        fraction: pctHigh,
        color: AppColors.red,
        label: 'Tinggi',
        percentage: '${(pctHigh * 100).round()}%',
        count: countHigh,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.bgLight.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.teal, AppColors.blue],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.donut_large_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori Dependensi',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Distribusi tingkat dependensi selama periode ini',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Chart + Legend ───────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut chart
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(140, 140),
                      painter: _DonutPainter(segments: segments, gapDegrees: 3),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$totalSurveys',
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                          const Text(
                            'KUESIONER',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: segments
                      .map((s) => _LegendItem(segment: s))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Legend Item ───────────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final _DonutSegment segment;

  const _LegendItem({required this.segment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Color dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: segment.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          // Label + percentage
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  segment.label,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  segment.percentage,
                  style: TextStyle(
                    color: segment.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Count badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: segment.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: segment.color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                '${segment.count}x',
                style: TextStyle(
                  color: segment.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data Model ────────────────────────────────────────────────────────────────

class _DonutSegment {
  final double fraction;
  final Color color;
  final String label;
  final String percentage;
  final int count;

  const _DonutSegment({
    required this.fraction,
    required this.color,
    required this.label,
    required this.percentage,
    required this.count,
  });
}

// ── Custom Painter ────────────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final double gapDegrees;

  const _DonutPainter({required this.segments, this.gapDegrees = 3});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 18.0;
    final radius = (size.width / 2) - strokeWidth / 2;

    final gapRad = gapDegrees * math.pi / 180;
    final totalGap = gapRad * segments.length;
    final availableAngle = 2 * math.pi - totalGap;

    // Background ring
    final bgPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    double startAngle = -math.pi / 2;

    for (final seg in segments) {
      if (seg.fraction <= 0) continue;

      final sweepAngle = availableAngle * seg.fraction;

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle + gapRad;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Legacy ChartData (dipertahankan agar tidak ada import error) ──────────────

class ChartData {
  final String label;
  final int value;

  ChartData(this.label, this.value);
}

// ── Legacy ProgressPerformanceChart (dipertahankan agar tidak ada import error)

class ProgressPerformanceChart extends StatelessWidget {
  final List<ChartData>? data;
  final String title;

  const ProgressPerformanceChart({
    super.key,
    this.data,
    this.title = 'Progress Performance',
  });

  @override
  Widget build(BuildContext context) {
    // Delegasikan ke DependencyDonutChart dengan data dummy
    return const DependencyDonutChart();
  }
}
