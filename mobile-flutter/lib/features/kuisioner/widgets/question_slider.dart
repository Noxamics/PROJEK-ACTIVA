//lib/features/kuisioner/widgets/question_slider.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM MONOCHROME SLIDER — Activa
// Large numeric display + navy/gray track. No rainbow colors.
// ─────────────────────────────────────────────────────────────────────────────

class QuestionSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final String? minLabel;
  final String? maxLabel;
  final String? qualityLabel;

  /// [activeColor] is kept for API compatibility but defaults to navy.
  /// Pass AppColors.teal only if you want a teal track for a specific question.
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const QuestionSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.onChanged,
    this.minLabel,
    this.maxLabel,
    this.qualityLabel,
    this.activeColor = const Color(0xFF1E3A5F), // navy default
  });

  // ── Design tokens ──────────────────────────────────────────────────────────
  static const Color _navy = Color(0xFF1E3A5F);
  static const Color _iceWhite = Color(0xFFF0F9FF);
  static const Color _softGray = Color(0xFFE5E7EB);
  static const Color _darkGray = Color(0xFF374151);
  static const Color _textMuted = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _iceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.12),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildValueDisplay(),
          const SizedBox(height: 24),
          _buildSlider(context),
          const SizedBox(height: 12),
          _buildLabels(),
        ],
      ),
    );
  }

  // ── Value display ──────────────────────────────────────────────────────────

  Widget _buildValueDisplay() {
    final displayVal = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);

    return Column(
      children: [
        // Large number
        Text(
          displayVal,
          style: TextStyle(
            color: activeColor,
            fontSize: 60,
            fontWeight: FontWeight.w900,
            letterSpacing: -3,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),

        // Unit
        Text(
          unit.toUpperCase(),
          style: TextStyle(
            color: activeColor.withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),

        // Quality label pill
        if (qualityLabel != null) ...[
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: activeColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Text(
              qualityLabel!,
              style: TextStyle(
                color: activeColor.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Slider ─────────────────────────────────────────────────────────────────

  Widget _buildSlider(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeColor,
        inactiveTrackColor: activeColor.withValues(alpha: 0.12),
        thumbColor: Colors.white,
        overlayColor: activeColor.withValues(alpha: 0.08),
        thumbShape: _MonochromeThumbShape(color: activeColor),
        trackHeight: 10,
        trackShape: const RoundedRectSliderTrackShape(),
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }

  // ── Labels ─────────────────────────────────────────────────────────────────

  Widget _buildLabels() {
    if (minLabel == null && maxLabel == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _labelText(minLabel ?? ''),
          _labelText(maxLabel ?? ''),
        ],
      ),
    );
  }

  Widget _labelText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM THUMB SHAPE
// ─────────────────────────────────────────────────────────────────────────────

class _MonochromeThumbShape extends SliderComponentShape {
  final Color color;
  const _MonochromeThumbShape({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(32, 32);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Drop shadow
    canvas.drawCircle(
      center + const Offset(0, 2),
      16,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // White outer circle
    canvas.drawCircle(center, 16, Paint()..color = Colors.white);

    // Colored inner dot
    canvas.drawCircle(center, 8, Paint()..color = color);
  }
}