// widgets/premium_setting_toggle.dart
//
// Replaces the old SettingItemToggle.
// Features: gradient icon, custom animated toggle switch with teal glow.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PremiumSettingToggle extends StatefulWidget {
  final IconData icon;
  final List<Color> iconGradient;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const PremiumSettingToggle({
    super.key,
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  State<PremiumSettingToggle> createState() => _PremiumSettingToggleState();
}

class _PremiumSettingToggleState extends State<PremiumSettingToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _toggleCtrl;
  late Animation<double> _toggleAnim;

  @override
  void initState() {
    super.initState();
    _toggleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.value ? 1.0 : 0.0,
    );
    _toggleAnim = CurvedAnimation(parent: _toggleCtrl, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(PremiumSettingToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      widget.value ? _toggleCtrl.forward() : _toggleCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _toggleCtrl.dispose();
    super.dispose();
  }

  void _handleToggle() {
    HapticFeedback.selectionClick();
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Gradient icon
              Container(
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
                        color: const Color(0xFF0D1F3C).withValues(alpha: 0.45),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Custom animated switch
              GestureDetector(
                onTap: _handleToggle,
                child: AnimatedBuilder(
                  animation: _toggleAnim,
                  builder: (_, __) {
                    final t = _toggleAnim.value;
                    return Container(
                      width: 52,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(
                              const Color(0xFFDDE3EE),
                              const Color(0xFF00E5C8),
                              t,
                            )!,
                            Color.lerp(
                              const Color(0xFFCDD5E0),
                              const Color(0xFF0099AA),
                              t,
                            )!,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF00E5C8,
                            ).withValues(alpha: 0.4 * t),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            left: widget.value ? 24 : 4,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
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
