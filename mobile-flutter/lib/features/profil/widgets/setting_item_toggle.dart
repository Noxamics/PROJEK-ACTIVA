import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingItemToggle extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const SettingItemToggle({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              Expanded(child: _buildLabel()),
              _buildSwitch(),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.05)),
          ),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  Widget _buildLabel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.7), 
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch() {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.teal,
      activeTrackColor: AppColors.teal.withValues(alpha: 0.2),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.shade200,
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }
}
