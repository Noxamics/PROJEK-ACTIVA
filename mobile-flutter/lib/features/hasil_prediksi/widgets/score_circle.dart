// lib/features/hasil_prediksi/widgets/score_circle.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScoreCircle extends StatefulWidget {
  final String score;
  final String label;
  final Color color;
  final double percent;
  final double size;
  final double fontSize;

  const ScoreCircle({
    super.key,
    required this.score,
    required this.label,
    required this.color,
    required this.percent,
    this.size = 80,
    this.fontSize = 22,
  });

  @override
  State<ScoreCircle> createState() => _ScoreCircleState();
}

class _ScoreCircleState extends State<ScoreCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, child) {
            return Container(
              width: widget.size + 40,
              height: widget.size + 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  // Outer glow — large, soft
                  BoxShadow(
                    color: widget.color.withValues(
                      alpha: _glowAnim.value * 0.5,
                    ),
                    blurRadius: widget.size * 0.55,
                    spreadRadius: widget.size * 0.10,
                  ),
                  // Inner glow — tight, bright
                  BoxShadow(
                    color: widget.color.withValues(
                      alpha: _glowAnim.value * 0.7,
                    ),
                    blurRadius: widget.size * 0.22,
                    spreadRadius: widget.size * 0.02,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Center(
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background track circle
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: widget.size * 0.08,
                    valueColor: AlwaysStoppedAnimation(
                      widget.color.withValues(alpha: 0.12),
                    ),
                  ),
                  // Foreground score arc
                  CircularProgressIndicator(
                    value: widget.percent,
                    strokeWidth: widget.size * 0.08,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(widget.color),
                    strokeCap: StrokeCap.round,
                  ),
                  // Score text center
                  Center(
                    child: Text(
                      widget.score,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
