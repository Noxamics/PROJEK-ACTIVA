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
          _buildScaleRow(), 
          const SizedBox(height: 16), 
          _buildLabels()
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

      return Padding(
        padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
        child: GestureDetector(
          onTap: () => onChanged(number),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            width: _boxWidth(total),
            height: _boxHeight(total),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.15),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: _fontSize(total),
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children
      ),
    );
  }

  Widget _buildLabels() {
    if (lowLabel == null && highLabel == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              lowLabel ?? '',
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              highLabel ?? '',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _boxWidth(int total) {
    if (total <= 5) return 58;
    if (total <= 10) return 42;
    return 34;
  }

  double _boxHeight(int total) {
    if (total <= 10) return 50;
    return 44;
  }

  double _fontSize(int total) {
    if (total <= 10) return 16;
    return 13;
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
      if (isHigh) return AppColors.red;
      if (isLow) return AppColors.green;
      return AppColors.amber;
    } else {
      if (isHigh) return AppColors.green;
      if (isLow) return AppColors.red;
      return AppColors.amber;
    }
  }
}
