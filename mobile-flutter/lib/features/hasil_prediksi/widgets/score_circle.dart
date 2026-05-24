// lib/features/hasil_prediksi/widgets/score_circle.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Color Tokens ─────────────────────────────────────────────────────────────

const _iceWhite = Color(0xFFF0F9FF);
const _deepNavy = Color(0xFF0B1F3A);

// ─── Glow Ring Painter ────────────────────────────────────────────────────────

class _GlowRingPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;
  final Color color;

  _GlowRingPainter({
    required this.progress,
    required this.glowIntensity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    final strokeWidth = math.max(size.width * 0.07, 8.0);

    // Outer ambient glow rings
    for (int i = 3; i >= 1; i--) {
      canvas.drawCircle(
        center,
        radius + i * 6.0,
        Paint()
          ..color = color.withValues(alpha: glowIntensity * 0.06 / i)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Track ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    // Progress arc with gradient shader
    final sweepAngle = progress * 2 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + sweepAngle,
          colors: [color.withValues(alpha: 0.5), color],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Glowing tip dot
    if (progress > 0.01) {
      final angle = -math.pi / 2 + sweepAngle;
      final tipX = center.dx + radius * math.cos(angle);
      final tipY = center.dy + radius * math.sin(angle);
      final tip = Offset(tipX, tipY);

      // Glow halo
      canvas.drawCircle(
        tip,
        strokeWidth * 0.7,
        Paint()
          ..color = color.withValues(alpha: 0.4 * glowIntensity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowIntensity * 8),
      );
      // White core
      canvas.drawCircle(tip, strokeWidth * 0.28, Paint()..color = _iceWhite);
    }
  }

  @override
  bool shouldRepaint(_GlowRingPainter old) =>
      old.progress != progress || old.glowIntensity != glowIntensity;
}

// ─── ScoreCircle ─────────────────────────────────────────────────────────────

/// Premium animated score orb with futuristic glow ring.
/// Drop-in replacement for the old ScoreCircle widget.
class ScoreCircle extends StatefulWidget {
  final String score;
  final String label;
  final Color color;

  /// Normalized progress value [0.0 – 1.0]
  final double percent;

  /// Diameter of the entire widget
  final double size;

  /// Font size for the score number
  final double fontSize;

  const ScoreCircle({
    super.key,
    required this.score,
    required this.label,
    required this.color,
    required this.percent,
    this.size = 160,
    this.fontSize = 48,
  });

  @override
  State<ScoreCircle> createState() => _ScoreCircleState();
}

class _ScoreCircleState extends State<ScoreCircle>
    with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final AnimationController _progressCtrl;
  late final AnimationController _floatCtrl;

  late final Animation<double> _glowAnim;
  late final Animation<double> _progressAnim;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    // Pulsing glow
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // Score fill animation on mount
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _progressAnim = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeOutCubic,
    );

    // Subtle floating
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(
      begin: -4.0,
      end: 4.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _progressCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSize = widget.size + 40;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_glowAnim, _progressAnim, _floatAnim]),
          builder: (_, __) {
            final glow = _glowAnim.value;
            final progress = _progressAnim.value * widget.percent;
            final dy = _floatAnim.value;

            return Transform.translate(
              offset: Offset(0, dy),
              child: SizedBox(
                width: totalSize,
                height: totalSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ambient glow
                    Container(
                      width: totalSize,
                      height: totalSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(
                              alpha: 0.08 + glow * 0.08,
                            ),
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    // Outer faint rings
                    for (final factor in [1.0, 0.92, 0.84])
                      Container(
                        width: totalSize * factor,
                        height: totalSize * factor,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.color.withValues(
                              alpha: 0.03 + glow * 0.02,
                            ),
                            width: 1,
                          ),
                        ),
                      ),

                    // Progress ring
                    CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _GlowRingPainter(
                        progress: progress,
                        glowIntensity: glow,
                        color: widget.color,
                      ),
                    ),

                    // Frosted inner orb
                    Container(
                      width: widget.size * 0.68,
                      height: widget.size * 0.68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.color.withValues(alpha: 0.14),
                            _deepNavy.withValues(alpha: 0.85),
                          ],
                        ),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.18),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(
                              alpha: 0.08 + glow * 0.06,
                            ),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.score,
                            style: TextStyle(
                              color: widget.color,
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2,
                              height: 1,
                              shadows: [
                                Shadow(
                                  color: widget.color.withValues(alpha: 0.5),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '/ 100',
                            style: TextStyle(
                              color: _iceWhite.withValues(alpha: 0.3),
                              fontSize: widget.fontSize * 0.22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        Text(
          widget.label,
          style: TextStyle(
            color: _iceWhite.withValues(alpha: 0.45),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
