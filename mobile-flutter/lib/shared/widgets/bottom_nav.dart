import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Tipe tampilan bottom nav — gelap (dark bg) atau terang (white bg).
enum NavTheme { dark, light }

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final NavTheme navTheme;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.navTheme = NavTheme.dark,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = navTheme == NavTheme.dark;

    final bgColor = isDark ? AppColors.bgCard : AppColors.bgWhite;
    final borderColor = isDark ? AppColors.cardBorder : AppColors.lightBorder;
    
    // Warna sesuai image reference (Slate palette)
    final activeColor = isDark ? Colors.white : AppColors.textDark;
    final inactiveColor = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor.withValues(alpha: 0.5)),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (i) => _buildNavItem(
                index: i,
                activeIcon: _navItems[i].activeIcon,
                inactiveIcon: _navItems[i].inactiveIcon,
                label: _navItems[i].label,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const _NavItem(this.activeIcon, this.inactiveIcon, this.label);
}

const _navItems = [
  _NavItem(Icons.home_rounded, Icons.home_outlined, 'Beranda'),
  _NavItem(Icons.assignment_rounded, Icons.assignment_outlined, 'Kuesioner'),
  _NavItem(Icons.description_rounded, Icons.description_outlined, 'Laporan'),
  _NavItem(Icons.show_chart_rounded, Icons.show_chart_rounded, 'Grafik'),
  _NavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
];
