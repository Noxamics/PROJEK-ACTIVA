import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

import '../widgets/setting_item.dart';
import '../widgets/setting_item_toggle.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../providers/notification_provider.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _onNavTap(int index) {
    if (index == 4) return; // Sudah di profil

    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const KuesionerScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LaporanPerkembanganScreen(),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GrafikScreen()),
        );
        break;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> _onLogout() async {
    Navigator.pop(context); // tutup dialog

    // Tampilkan loading overlay selama proses logout
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.teal,
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Sedang keluar...',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    HapticFeedback.lightImpact();
    await ref.read(authProvider.notifier).logout();

    // Beri sedikit delay agar loading terasa natural
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      // Navigasi ke LoginScreen & hapus seluruh stack
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, _) => const LoginScreen(),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );

      // Snackbar konfirmasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Berhasil keluar dari akun',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Ambil data user dari provider
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildProfileHeader(user),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPengaturanSection(),
                        const SizedBox(height: 32),
                        _buildKeluarButton(),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'DigitalLife Analyzer v1.0.0',
                            style: TextStyle(
                              color: AppColors.textMuted.withValues(alpha: 0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            BottomNav(
              currentIndex: 4,
              navTheme: NavTheme.light,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  // ── Profile Header ─────────────────────────────────────────────────────────

  Widget _buildProfileHeader(user) {
    final name = user?.name ?? 'Pengguna';
    final email = user?.email ?? 'pengguna@email.com';
    final initials = user?.initials ?? '?';
    final age = user?.age.toString() ?? '-';
    final edu = user?.educationLevel ?? '-';
    final region = user?.region ?? '-';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        children: [
          _buildAvatar(initials),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _buildTags(age: age, edu: edu, region: region),
        ],
      ),
    );
  }

  Widget _buildAvatar(String initials) {
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2), width: 2),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.teal, Color(0xFF2DD4BF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTags({
    required String age,
    required String edu,
    required String region,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _buildTag(Icons.cake_outlined, '$age thn'),
        _buildTag(Icons.school_outlined, edu),
        _buildTag(Icons.location_on_outlined, region),
      ],
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Pengaturan Section ─────────────────────────────────────────────────────

  Widget _buildPengaturanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'PENGATURAN',
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
          child: Column(
            children: [
              SettingItem(
                icon: Icons.person_outline_rounded,
                iconBg: AppColors.teal.withValues(alpha: 0.08),
                iconColor: AppColors.teal,
                title: 'Data Diri',
                subtitle: 'Edit profil & informasi personal',
                onTap: () {},
              ),
              SettingItemToggle(
                icon: Icons.notifications_none_rounded,
                iconBg: AppColors.blue.withValues(alpha: 0.08),
                iconColor: AppColors.blue,
                title: 'Notifikasi',
                subtitle: 'Pengingat kuesioner harian',
                value: ref.watch(notificationProvider),
                onChanged: (v) => ref.read(notificationProvider.notifier).toggle(v),
              ),
              SettingItem(
                icon: Icons.file_download_outlined,
                iconBg: AppColors.amber.withValues(alpha: 0.08),
                iconColor: AppColors.amber,
                title: 'Ekspor Data',
                subtitle: 'Unduh hasil analisis periode ini',
                onTap: () {},
              ),
              SettingItem(
                icon: Icons.help_outline_rounded,
                iconBg: Colors.purple.withValues(alpha: 0.08),
                iconColor: Colors.purple,
                title: 'Bantuan',
                subtitle: 'Pusat bantuan & FAQ',
                onTap: () {},
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Keluar Button ──────────────────────────────────────────────────────────

  Widget _buildKeluarButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _showKeluarDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red.withValues(alpha: 0.06),
          foregroundColor: AppColors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: AppColors.red.withValues(alpha: 0.1), width: 1.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 10),
            Text(
              'Keluar dari Akun',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  void _showKeluarDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Keluar dari Akun?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Sesi Anda akan berakhir dan Anda perlu masuk kembali nanti.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
