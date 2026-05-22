// lib/features/kuisioner/widgets/question_option_card.dart

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS — Activa Premium Monochrome
// ─────────────────────────────────────────────────────────────────────────────

class _AT {
  static const Color navy = Color(0xFF1E3A5F);
  static const Color teal = Color(0xFF0D9488);
  static const Color iceWhite = Color(0xFFF0F9FF);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color borderDef = Color(0xFFE5E7EB);
  static const Color darkGray = Color(0xFF374151);
  static const Color black = Color(0xFF111827);
}

// ─────────────────────────────────────────────────────────────────────────────
// OPTION CARD  (title only — no subtitle inside the card)
// ─────────────────────────────────────────────────────────────────────────────

class QuestionOptionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const QuestionOptionCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? _AT.iceWhite : _AT.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _AT.teal : _AT.borderDef,
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _AT.teal.withValues(alpha: 0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: _AT.navy.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Label ──────────────────────────────────────────────────────
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? _AT.black : _AT.darkGray,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRID OPTION DATA
// ─────────────────────────────────────────────────────────────────────────────

class GridOptionData {
  final String label;
  final String description; // shown in the panel below, NOT inside the card
  final dynamic value;

  const GridOptionData({
    required this.label,
    required this.description,
    required this.value,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// FIVE OPTION GRID PICKER
// Layout:  [0] [1]
//          [2] [3]
//             [4]   (centered, ~44 % width)
//
// Selected description appears BELOW all cards in a dedicated panel.
// ─────────────────────────────────────────────────────────────────────────────

class FiveOptionGridPicker extends StatelessWidget {
  final List<GridOptionData> options;
  final dynamic selectedValue;
  final ValueChanged<dynamic> onChanged;

  const FiveOptionGridPicker({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  }) : assert(
         options.length == 5,
         'FiveOptionGridPicker requires exactly 5 options',
       );

  @override
  Widget build(BuildContext context) {
    final selectedOpt = options.cast<GridOptionData?>().firstWhere(
      (o) => o!.value == selectedValue,
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Row 1 ────────────────────────────────────────────────────────
        Row(
          children: [
            // Icon/Prefix
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.teal.withValues(alpha: 0.15)
                      : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.teal : AppColors.textMuted,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
            ],

            // Label & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppColors.teal : AppColors.textDark,
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.teal.withValues(alpha: 0.7)
                            : AppColors.textMuted,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.teal : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.teal : AppColors.textDisabled,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.teal.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
