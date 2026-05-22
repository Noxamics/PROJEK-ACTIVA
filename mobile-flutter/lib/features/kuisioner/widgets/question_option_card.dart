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
            Expanded(child: _card(options[0])),
            const SizedBox(width: 10),
            Expanded(child: _card(options[1])),
          ],
        ),
        const SizedBox(height: 10),

        // ── Row 2 ────────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(child: _card(options[2])),
            const SizedBox(width: 10),
            Expanded(child: _card(options[3])),
          ],
        ),
        const SizedBox(height: 10),

        // ── Row 3 — fifth option centered ────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.44,
              child: _card(options[4]),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Description panel ─────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            ),
          ),
          child: selectedOpt != null
              ? _DescriptionPanel(
                  key: ValueKey(selectedOpt.value),
                  label: selectedOpt.label,
                  description: selectedOpt.description,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _card(GridOptionData opt) {
    return QuestionOptionCard(
      label: opt.label,
      isSelected: opt.value == selectedValue,
      onTap: () => onChanged(opt.value),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESCRIPTION PANEL
// ─────────────────────────────────────────────────────────────────────────────

class _DescriptionPanel extends StatelessWidget {
  final String label;
  final String description;

  const _DescriptionPanel({
    super.key,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: _AT.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AT.borderDef, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: _AT.navy),
              const SizedBox(width: 6),
              Text(
                'KETERANGAN',
                style: TextStyle(
                  color: _AT.navy,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: _AT.borderDef, height: 1, thickness: 1),
          const SizedBox(height: 10),

          // ── Description text ──────────────────────────────────────────
          Text(
            description,
            style: const TextStyle(
              color: _AT.darkGray,
              fontSize: 11.5,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
