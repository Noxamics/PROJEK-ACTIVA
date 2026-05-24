//lib/features/kuisioner/widgets/role_option.dart

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM MONOCHROME ROLE OPTION — Activa
// Used for role/type selection. Navy selected state, white default.
// ─────────────────────────────────────────────────────────────────────────────

class RoleOption extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  // ── Design tokens ──────────────────────────────────────────────────────────
  static const Color _navy = Color(0xFF1E3A5F);
  static const Color _softGray = Color(0xFFE5E7EB);
  static const Color _darkGray = Color(0xFF374151);
  static const Color _textMuted = Color(0xFF9CA3AF);
  static const Color _iceWhite = Color(0xFFF0F9FF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? _navy : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _navy : _softGray,
            width: isSelected ? 0 : 1.4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _navy.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            // ── Radio circle ────────────────────────────────────────────────
            _RadioCircle(isSelected: isSelected),
            const SizedBox(width: 14),

            // ── Icon (optional) ─────────────────────────────────────────────
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.9)
                    : _textMuted,
              ),
              const SizedBox(width: 10),
            ],

            // ── Labels ──────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _darkGray,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.6)
                            : _textMuted,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INNER — RADIO CIRCLE
// ─────────────────────────────────────────────────────────────────────────────

class _RadioCircle extends StatelessWidget {
  final bool isSelected;
  const _RadioCircle({required this.isSelected});

  static const Color _navy = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.white : Colors.transparent,
        border: Border.all(
          color: isSelected ? Colors.white : const Color(0xFFD1D5DB),
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _navy,
                ),
              ),
            )
          : null,
    );
  }
}
