import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ── Simple Line Chart (untuk Dependence & Screen Time) ─────────────────────
class SimpleLineChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double maxValue;

  const SimpleLineChart({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    this.maxValue = 100,
  });

  @override
  State<SimpleLineChart> createState() => _SimpleLineChartState();
}

class _SimpleLineChartState extends State<SimpleLineChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final displayIndex =
        _selectedIndex ??
        (widget.values.isNotEmpty ? widget.values.length - 1 : null);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Area
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onPanUpdate: (details) => _handleTouch(
                            details.localPosition,
                            constraints.maxWidth,
                          ),
                          onTapDown: (details) => _handleTouch(
                            details.localPosition,
                            constraints.maxWidth,
                          ),
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _LineChartPainter(
                              values: widget.values,
                              color: widget.color,
                              maxValue: widget.maxValue,
                              selectedIndex: _selectedIndex,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // X-Axis Labels (aligned perfectly with dots)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (widget.labels.isEmpty) return const SizedBox(height: 16);
                      final stepX = widget.labels.length > 1
                          ? constraints.maxWidth / (widget.labels.length - 1)
                          : 0.0;
                      return SizedBox(
                        height: 16,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: List.generate(widget.labels.length, (i) {
                            return Positioned(
                              left: (i * stepX) - 30, // 30 is half of 60 to center the text
                              width: 60,
                              child: Text(
                                widget.labels[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textMuted.withValues(alpha: 0.6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Side Info Panel
            if (displayIndex != null)
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: widget.color.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'INFO',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.values[displayIndex].toStringAsFixed(widget.maxValue > 50 ? 0 : 1),
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.labels[displayIndex],
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Expanded(flex: 1, child: SizedBox()),
          ],
        ),
      ],
    );
  }

  void _handleTouch(Offset localPosition, double maxWidth) {
    if (widget.values.length < 2) return;

    final stepX = maxWidth / (widget.values.length - 1);
    int index = (localPosition.dx / stepX).round().clamp(
      0,
      widget.values.length - 1,
    );

    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double maxValue;
  final int? selectedIndex;

  _LineChartPainter({
    required this.values,
    required this.color,
    required this.maxValue,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    if (values.length < 2) {
      final x = size.width / 2;
      final y = size.height - (values[0] / maxValue * size.height).clamp(0.0, size.height);
      
      final highlightPaint = Paint()..color = color.withValues(alpha: 0.2);
      canvas.drawCircle(Offset(x, y), 10, highlightPaint);
      
      final outerDotPaint = Paint()..color = color;
      canvas.drawCircle(Offset(x, y), 6, outerDotPaint);
      
      final innerDotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(x, y), 3, innerDotPaint);
      return;
    }

    final stepX = size.width / (values.length - 1);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw grid line for selected index
    if (selectedIndex != null) {
      final x = selectedIndex! * stepX;
      final selectedGridPaint = Paint()
        ..color = color.withValues(alpha: 0.15)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), selectedGridPaint);
    }

    // Path for the line
    final path = Path();
    final fillPath = Path();
    
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxValue * size.height).clamp(0.0, size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // Smooth curve using cubic bezier
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (values[i - 1] / maxValue * size.height).clamp(0.0, size.height);
        
        path.cubicTo(
          prevX + (x - prevX) / 2, prevY,
          prevX + (x - prevX) / 2, y,
          x, y
        );
        fillPath.cubicTo(
          prevX + (x - prevX) / 2, prevY,
          prevX + (x - prevX) / 2, y,
          x, y
        );
      }
      
      if (i == values.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    // Draw fill with gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Draw dots
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxValue * size.height).clamp(0.0, size.height);

      final isSelected = i == selectedIndex;
      
      if (isSelected) {
        final highlightPaint = Paint()..color = color.withValues(alpha: 0.2);
        canvas.drawCircle(Offset(x, y), 10, highlightPaint);
        
        final outerDotPaint = Paint()..color = color;
        canvas.drawCircle(Offset(x, y), 6, outerDotPaint);
        
        final innerDotPaint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(x, y), 3, innerDotPaint);
      } else {
        final dotPaint = Paint()..color = color.withValues(alpha: 0.8);
        canvas.drawCircle(Offset(x, y), 4, dotPaint);
        
        final innerDotPaint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(x, y), 2, innerDotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.values != values;
}

// ── Generic Bar Chart (untuk Sosmed & Sleep) ────────────────────────────────
class GenericBarChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double maxValue;

  const GenericBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    required this.maxValue,
  });

  @override
  State<GenericBarChart> createState() => _GenericBarChartState();
}

class _GenericBarChartState extends State<GenericBarChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final displayIndex =
        _selectedIndex ??
        (widget.values.isNotEmpty ? widget.values.length - 1 : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart Area
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(widget.values.length, (i) {
                final hFactor = (widget.values[i] / widget.maxValue).clamp(0.05, 1.0);
                final isSelected = i == _selectedIndex;

                return Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _selectedIndex = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Background bar
                                Container(
                                  decoration: BoxDecoration(
                                    color: widget.color.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                // Active bar
                                FractionallySizedBox(
                                  heightFactor: hFactor,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOutCubic,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [widget.color, widget.color.withValues(alpha: 0.8)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? widget.color.withValues(alpha: 0.3)
                                              : widget.color.withValues(alpha: 0.0),
                                          blurRadius: 8,
                                          offset: isSelected ? const Offset(0, 4) : Offset.zero,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.textDark,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        widget.values[i].toInt().toString(),
                                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.labels[i],
                          style: TextStyle(
                            color: isSelected ? AppColors.textDark : AppColors.textMuted.withValues(alpha: 0.6),
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Side Info Panel
        if (displayIndex != null)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.color.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.values[displayIndex].toInt()}',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.labels[displayIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          )
        else
          const Expanded(flex: 1, child: SizedBox()),
      ],
    );
  }
}

// ── Donut Chart (untuk Kategori Rendah/Sedang/Tinggi) ────────────────────────
class DonutChartWidget extends StatelessWidget {
  final int low;
  final int medium;
  final int high;

  const DonutChartWidget({
    super.key,
    required this.low,
    required this.medium,
    required this.high,
  });

  @override
  Widget build(BuildContext context) {
    final total = low + medium + high;
    if (total == 0) return const Center(child: Text('Belum ada data tersedia.'));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: _DonutPainter(low: low, medium: medium, high: high),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'KUESIONER',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(AppColors.teal, 'Rendah', low, total),
                const SizedBox(height: 14),
                _legendItem(AppColors.amber, 'Sedang', medium, total),
                const SizedBox(height: 14),
                _legendItem(AppColors.red, 'Tinggi', high, total),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, int count, int total) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'x',
          style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int low, medium, high;
  _DonutPainter({required this.low, required this.medium, required this.high});

  @override
  void paint(Canvas canvas, Size size) {
    final total = low + medium + high;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    // Draw background track
    final trackPaint = Paint()
      ..color = AppColors.bgLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawCircle(center, radius - 10, trackPaint);

    double startAngle = -math.pi / 2;

    void drawSegment(int count, Color color) {
      if (count == 0) return;
      final sweepAngle = (count / total) * 2 * math.pi;
      
      paint.color = color;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        startAngle + 0.1,
        sweepAngle - 0.2,
        false,
        paint,
      );
      
      startAngle += sweepAngle;
    }

    drawSegment(low, AppColors.teal);
    drawSegment(medium, AppColors.amber);
    drawSegment(high, AppColors.red);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}