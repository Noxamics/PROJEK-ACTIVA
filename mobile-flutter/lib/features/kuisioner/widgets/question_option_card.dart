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
// OPTION CARD
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
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 10,
        ),
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
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? _AT.black : _AT.darkGray,
              fontSize: 11.5,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w600,
              height: 1.2,
              letterSpacing: -0.1,
            ),
          ),
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
  final String description;
  final dynamic value;

  const GridOptionData({
    required this.label,
    required this.description,
    required this.value,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// FIVE OPTION GRID PICKER
//
// Layout:
// [0] [1]
// [2] [3]
//    [4]
//
// Selected description appears below
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

    Widget buildCard(GridOptionData option) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: QuestionOptionCard(
            label: option.label,
            isSelected: selectedValue == option.value,
            onTap: () => onChanged(option.value),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ───────────────── Row 1 ─────────────────
        Row(
          children: [
            buildCard(options[0]),
            buildCard(options[1]),
          ],
        ),

        // ───────────────── Row 2 ─────────────────
        Row(
          children: [
            buildCard(options[2]),
            buildCard(options[3]),
          ],
        ),

        // ───────────────── Row 3 ─────────────────
        Row(
          children: [
            const Spacer(),

            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: QuestionOptionCard(
                  label: options[4].label,
                  isSelected:
                      selectedValue == options[4].value,
                  onTap: () =>
                      onChanged(options[4].value),
                ),
              ),
            ),

            const Spacer(),
          ],
        ),

        // ───────────────── Description Panel ─────────────────
        if (selectedOpt != null) ...[
          const SizedBox(height: 14),

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _AT.iceWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _AT.teal.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              selectedOpt.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: _AT.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}