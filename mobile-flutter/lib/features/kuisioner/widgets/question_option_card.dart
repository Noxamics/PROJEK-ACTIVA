//lib/features/kuisioner/widgets/question_option_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget pilihan jawaban dengan tampilan card yang fresh dan premium.
class QuestionOptionCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const QuestionOptionCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.teal.withValues(alpha: 0.08)
              : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.teal : AppColors.lightBorder,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.teal.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
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
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.teal.withValues(alpha: 0.3)
                        : AppColors.teal.withValues(alpha: 0.0),
                    blurRadius: 6,
                    offset: isSelected ? const Offset(0, 2) : Offset.zero,
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
