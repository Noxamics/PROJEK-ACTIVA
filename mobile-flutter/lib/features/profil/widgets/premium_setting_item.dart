// widgets/premium_setting_item.dart
//
// Replaces the old SettingItem.
// Features: gradient icon pill, title, subtitle, arrow, tap scale animation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PremiumSettingItem extends StatefulWidget {
  final IconData icon;
  final List<Color> iconGradient;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  const PremiumSettingItem({
    super.key,
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  State<PremiumSettingItem> createState() => _PremiumSettingItemState();
}

class _PremiumSettingItemState extends State<PremiumSettingItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) {
            setState(() => _pressed = true);
            HapticFeedback.selectionClick();
          },
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            color: _pressed
                ? Colors.black.withValues(alpha: 0.03)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Gradient icon container
                AnimatedScale(
                  scale: _pressed ? 0.92 : 1.0,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.iconGradient,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: widget.iconGradient[0].withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 22),
                  ),
                ),

                const SizedBox(width: 16),

                // Labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Color(0xFF0D1F3C),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: const Color(
                            0xFF0D1F3C,
                          ).withValues(alpha: 0.45),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: const Color(0xFF0D1F3C).withValues(alpha: 0.25),
                  size: 13,
                ),
              ],
            ),
          ),
        ),

        if (widget.showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ),
      ],
    );
  }
}
