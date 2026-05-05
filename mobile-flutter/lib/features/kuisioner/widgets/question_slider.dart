import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget slider untuk pertanyaan numerik.
/// Dipakai untuk: jam pakai HP, menit sosmed, jam tidur, dll.
class QuestionSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit; // satuan: "jam", "menit", "kali", "hari"
  final String? minLabel;
  final String? maxLabel;
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
    this.activeColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
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

  // ── Value Display ──────────────────────────────────────────────────────────

  Widget _buildValueDisplay() {
    final displayVal = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);

    return Column(
      children: [
        Text(
          displayVal,
          style: TextStyle(
            color: activeColor,
            fontSize: 44,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        Text(
          unit.toUpperCase(),
          style: TextStyle(
            color: activeColor.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Slider ─────────────────────────────────────────────────────────────────

  Widget _buildSlider(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeColor,
        inactiveTrackColor: activeColor.withValues(alpha: 0.1),
        thumbColor: Colors.white,
        overlayColor: activeColor.withValues(alpha: 0.1),
        thumbShape: _CustomThumbShape(color: activeColor),
        trackHeight: 8,
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            minLabel ?? '',
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            maxLabel ?? '',
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final Color color;
  const _CustomThumbShape({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(28, 28);

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

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Shadow
    canvas.drawCircle(center, 14, Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    // Outer circle (white)
    canvas.drawCircle(center, 14, paint);

    // Inner circle (colored)
    canvas.drawCircle(center, 8, Paint()..color = color);
  }
}
