// lib/features/hasil_prediksi/widgets/trend_bar_chart.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Color Tokens ─────────────────────────────────────────────────────────────

const _iceWhite = Color(0xFFF0F9FF);
const _teal = Color(0xFF0D9488);
const _cyan = Color(0xFF67E8F9);
const _navy = Color(0xFF1E3A5F);
const _deepNavy = Color(0xFF0B1F3A);

// ─── Painters ─────────────────────────────────────────────────────────────────

class _LineChartPainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final double animValue;

  _LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final count = points.length;
    final step = size.width / (count - 1);
    final visibleCount = (animValue * count).ceil().clamp(2, count);

    // Build smooth path using cubicTo
    final pts = <Offset>[];
    for (int i = 0; i < count; i++) {
      pts.add(
        Offset(
          i * step,
          size.height - points[i] * size.height * 0.85 - size.height * 0.05,
        ),
      );
    }

    final path = Path();
    path.moveTo(pts[0].dx, pts[0].dy);

    for (int i = 0; i < visibleCount - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      path.cubicTo(
        cp1.dx,
        cp1.dy,
        cp2.dx,
        cp2.dy,
        pts[i + 1].dx,
        pts[i + 1].dy,
      );
    }

    // Fill gradient
    final fillPath = Path.from(path)
      ..lineTo(pts[visibleCount - 1].dx, size.height)
      ..lineTo(pts[0].dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.18),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Glow line
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Solid line
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots
    for (int i = 0; i < visibleCount; i++) {
      // Outer glow
      canvas.drawCircle(
        pts[i],
        6,
        Paint()
          ..color = lineColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // Colored ring
      canvas.drawCircle(pts[i], 4, Paint()..color = lineColor);
      // White core
      canvas.drawCircle(pts[i], 2.2, Paint()..color = _iceWhite);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.animValue != animValue || old.points != points;
}

class _GridPainter extends CustomPainter {
  final int gridLines;
  _GridPainter({this.gridLines = 4});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _iceWhite.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (int i = 0; i <= gridLines; i++) {
      final y = size.height * i / gridLines;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

// ─── TrendBarChart (now a glowing line chart) ─────────────────────────────────

/// Renamed from TrendBarChart but kept the class name for drop-in compatibility.
/// Now renders a futuristic glowing smooth line chart instead of bar columns.
class TrendBarChart extends StatefulWidget {
  /// Normalized data points [0.0 – 1.0]. Defaults to 7-day sample.
  final List<double> dataPoints;

  /// Labels shown below each point. Must match dataPoints length.
  final List<String> labels;

  /// Chart color – defaults to the app teal.
  final Color color;

  const TrendBarChart({
    super.key,
    this.dataPoints = const [0.72, 0.68, 0.75, 0.62, 0.58, 0.55, 0.52],
    this.labels = const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
    this.color = _teal,
  });

  @override
  State<TrendBarChart> createState() => _TrendBarChartState();
}

class _TrendBarChartState extends State<TrendBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _deepNavy],
        ),
        border: Border.all(color: _iceWhite.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('📈', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text(
                'Trend 7 Hari',
                style: TextStyle(
                  color: _iceWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _teal.withValues(alpha: 0.12),
                ),
                child: const Text(
                  'Minggu ini',
                  style: TextStyle(
                    color: _teal,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart area
          SizedBox(
            height: 100,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Stack(
                children: [
                  // Grid
                  CustomPaint(
                    painter: _GridPainter(),
                    child: const SizedBox.expand(),
                  ),
                  // Line chart
                  CustomPaint(
                    painter: _LineChartPainter(
                      points: widget.dataPoints,
                      lineColor: widget.color,
                      animValue: _anim.value,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.labels
                .map(
                  (l) => Text(
                    l,
                    style: TextStyle(
                      color: _iceWhite.withValues(alpha: 0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 14),

          // Caption
          Text(
            'Kondisi digitalmu mulai lebih stabil dibanding minggu lalu.',
            style: TextStyle(
              color: _iceWhite.withValues(alpha: 0.45),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
