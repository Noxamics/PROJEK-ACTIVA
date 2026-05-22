//lib/features/kuisioner/widgets/question_scale_picker.dart

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM MONOCHROME SCALE PICKER — Activa
// Renders a 1–N tap-to-select row.
// All colours are navy/gray; no red/green/rainbow.
// ─────────────────────────────────────────────────────────────────────────────

class QuestionScalePicker extends StatelessWidget {
  final num value;
  final int min;
  final int max;
  final String? lowLabel;
  final String? highLabel;

  /// Kept for API compatibility — no longer changes colours in monochrome mode.
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

  // ── Design tokens ──────────────────────────────────────────────────────────
  static const Color _navy = Color(0xFF1E3A5F);
  static const Color _navyLight = Color(0xFF2D5186);
  static const Color _softGray = Color(0xFFE5E7EB);
  static const Color _darkGray = Color(0xFF374151);
  static const Color _textMuted = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (lowLabel != null || highLabel != null) ...[
          _buildLabels(),
          const SizedBox(height: 12),
        ],
        _buildScaleRow(),
      ],
    );
  }

  Widget _buildLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_labelText(lowLabel ?? ''), _labelText(highLabel ?? '')],
      ),
    );
  }

  Widget _labelText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildScaleRow() {
    final selectedInt = value.round();
    final total = max - min + 1;

    return Row(
      children: List.generate(total, (i) {
        final number = min + i;
        final isSelected = number == selectedInt;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(number),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? _navy : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? _navy : _softGray,
                  width: isSelected ? 0 : 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _navy.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: isSelected ? Colors.white : _darkGray,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
