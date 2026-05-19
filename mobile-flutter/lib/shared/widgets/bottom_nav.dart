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
    this.navTheme = NavTheme.light,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = navTheme == NavTheme.dark;

    final bgColor = isDark ? AppColors.bgCard : Colors.white;
    final borderColor = isDark ? AppColors.cardBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor.withValues(alpha: 0.3)),
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
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (i) => _buildNavItem(
                index: i,
                activeIcon: _navItems[i].activeIcon,
                inactiveIcon: _navItems[i].inactiveIcon,
                label: _navItems[i].label,
                isDark: isDark,
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
    required bool isDark,
  }) {
    final isActive = index == currentIndex;

    // Warna background icon aktif: navy/teal
    final activeIconBgColor = isDark
        ? AppColors.teal
        : const Color(0xFF1E2A4A); // Navy

    // Warna icon aktif: putih
    final activeIconColor = Colors.white;

    // Warna label aktif: navy untuk light, putih untuk dark
    final activeLabelColor = isDark
        ? AppColors.bgWhite
        : const Color(0xFF1E2A4A);

    // Warna item tidak aktif
    final inactiveColor = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFF1E2A4A).withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container dengan background jika aktif
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive ? activeIconBgColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive ? activeIconColor : inactiveColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeLabelColor : inactiveColor,
                fontSize: 10,
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
  _NavItem(Icons.article_rounded, Icons.article_outlined, 'Laporan'),
  _NavItem(Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Grafik'),
  _NavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
];
