import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScoreCard extends StatelessWidget {
  final String label;
  final String value;
  final String? category;
  final Color color;

  const ScoreCard({
    super.key,
    required this.label,
    required this.value,
    this.category,
    this.color = AppColors.textMuted,
  });

  Color get _displayColor {
    if (category == null) return color;
    final cat = category!.toLowerCase();
    if (cat.contains('rendah') || cat.contains('low')) return AppColors.teal;
    if (cat.contains('sedang') || cat.contains('moderate')) return AppColors.amber;
    if (cat.contains('tinggi') || cat.contains('high')) return AppColors.red;
    return color;
  }

  String get _categoryLabel {
    if (category == null) return '';
    final cat = category!.toLowerCase();
    if (cat.contains('rendah') || cat.contains('low')) return 'Rendah';
    if (cat.contains('sedang') || cat.contains('moderate')) return 'Sedang';
    if (cat.contains('tinggi') || cat.contains('high')) return 'Tinggi';
    return category!.substring(0, 1).toUpperCase() + category!.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final displayColor = _displayColor;
    final catLabel = _categoryLabel;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle background decoration
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: displayColor.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: displayColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.speed_rounded,
                    color: displayColor,
                    size: 16,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  label.replaceAll('\n', ' '),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'pt',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (catLabel.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• $catLabel',
                        style: TextStyle(
                          color: displayColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // Tiny progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (double.tryParse(value) ?? 0) / 100,
                    backgroundColor: displayColor.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(displayColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
