//lib/features/kuisioner/widgets/question_scale_picker.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget skala angka untuk pertanyaan kondisi mental.
/// Menerima value bertipe num (int atau double).
/// onChanged mengembalikan int.
///
/// [invertColor] = false (default):
///   nilai rendah = merah, nilai tinggi = hijau
///   → dipakai untuk happiness (tinggi = bagus)
///
/// [invertColor] = true:
///   nilai rendah = hijau, nilai tinggi = merah
///   → dipakai untuk anxiety, depresi, stres (tinggi = buruk)
class QuestionScalePicker extends StatelessWidget {
  final num value;
  final int min;
  final int max;
  final String? lowLabel;
  final String? highLabel;
  final bool invertColor;
  final ValueChanged<int> onChanged;

  const QuestionScalePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 10,
    this.lowLabel,
    this.highLabel,
    this.invertColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildLabels(), const SizedBox(height: 12), _buildScaleRow()],
    );
  }

  Widget _buildLabels() {
    if (lowLabel == null && highLabel == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            lowLabel ?? '',
            style: TextStyle(
              color: invertColor ? AppColors.green : AppColors.red,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            highLabel ?? '',
            style: TextStyle(
              color: invertColor ? AppColors.red : AppColors.green,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleRow() {
    final selectedInt = value.round();
    final total = max - min + 1;

    final children = List.generate(total, (i) {
      final number = min + i;
      final isSelected = number == selectedInt;
      final color = _colorForValue(number);

      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(number),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.3),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    });

    return Row(children: children);
  }

  // ── Warna berdasarkan posisi & mode ───────────────────────────────────────
  Color _colorForValue(int val) {
    final total = max - min + 1;
    final position = val - min; // 0-based

    final lowEnd = (total * 0.33).floor();
    final highEnd = (total * 0.67).floor();

    final isLow = position < lowEnd;
    final isHigh = position >= highEnd;

    if (invertColor) {
      // Untuk stress/anxiety: rendah = hijau, tinggi = merah
      if (isLow) return AppColors.green;
      if (isHigh) return AppColors.red;
      return AppColors.amber;
    } else {
      // Untuk happiness: rendah = merah, tinggi = hijau
      if (isLow) return AppColors.red;
      if (isHigh) return AppColors.green;
      return AppColors.amber;
    }
  }
}
