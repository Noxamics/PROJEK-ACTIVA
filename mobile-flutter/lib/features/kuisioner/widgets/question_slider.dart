//lib/features/kuisioner/widgets/question_slider.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget slider untuk pertanyaan numerik dengan tampilan premium.
/// Menampilkan nilai besar di tengah dengan label kualitas.
class QuestionSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final String? minLabel;
  final String? maxLabel;
  final String? qualityLabel;
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
    this.activeColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
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

  // ── Value Display ──────────────────────────────────────────────────────────

  Widget _buildValueDisplay() {
    final displayVal = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);

    return Column(
      children: [
        // Large value
        Text(
          displayVal,
          style: TextStyle(
            color: activeColor,
            fontSize: 56,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        // Unit label
        Text(
          unit.toUpperCase(),
          style: TextStyle(
            color: activeColor.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        // Quality label
        if (qualityLabel != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              qualityLabel!,
              style: TextStyle(
                color: activeColor,
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
        inactiveTrackColor: activeColor.withValues(alpha: 0.15),
        thumbColor: Colors.white,
        overlayColor: activeColor.withValues(alpha: 0.1),
        thumbShape: _CustomThumbShape(color: activeColor),
        trackHeight: 10,
        trackShape: const RoundedRectSliderTrackShape(),
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: activeColor.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
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
          Text(
            minLabel ?? '',
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            maxLabel ?? '',
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Thumb Shape ───────────────────────────────────────────────────────

class _CustomThumbShape extends SliderComponentShape {
  final Color color;
  const _CustomThumbShape({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(32, 32);

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
    final Canvas canvas = context.canvas;

    // Outer shadow
    canvas.drawCircle(
      center + const Offset(0, 2),
      16,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // White outer circle
    canvas.drawCircle(
      center,
      16,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Colored inner circle
    canvas.drawCircle(center, 8, Paint()..color = color);
  }
}
