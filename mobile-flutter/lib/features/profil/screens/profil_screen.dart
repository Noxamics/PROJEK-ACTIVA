// screens/profil_screen.dart
//
// ╔══════════════════════════════════════════════════════════════════╗
// ║  ACTIVA — Premium Futuristic AI Wellness Profile                ║
// ║  Rebuilt from scratch: immersive, animated, glassmorphism       ║
// ╚══════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/local_storage.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../providers/notification_provider.dart';
import '../widgets/futuristic_avatar.dart';
import '../widgets/glassmorphism_chip.dart';
import '../widgets/premium_setting_item.dart';
import '../widgets/premium_setting_toggle.dart';
import '../widgets/floating_particles.dart';
import 'edit_profil_screen.dart';

// ── Constants ──────────────────────────────────────────────────────────────────

class _PC {
  static const navy900 = Color(0xFF050D1A);
  static const navy800 = Color(0xFF091528);
  static const teal = Color(0xFF00E5C8);
  static const blue = Color(0xFF4B9FFF);
  static const rose = Color(0xFFFF6B8A);
  static const glassBorder = Color(0x25FFFFFF);
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.moveTo(0, size.height * 0.5);
    p.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.5);
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ── Main Screen ────────────────────────────────────────────────────────────────

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heroCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _cardCtrl;

  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _pulse;
  late final Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();

    // Hero entrance
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    // Avatar pulse glow
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    // Card stagger
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);

    // Trigger animations
    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _pulseCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  void _onNavTap(int index) {
    if (index == 4) return;
    switch (index) {
      case 0:
        Navigator.popUntil(context, (r) => r.isFirst);
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const KuesionerScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPerkembanganScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GrafikScreen()),
        );
        break;
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────────

  Future<void> _onLogout() async {
    Navigator.pop(context);

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
              color: _PC.navy800,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _PC.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: _PC.teal.withValues(alpha: 0.15),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: _PC.teal,
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sedang keluar...',
                  style: TextStyle(
                    color: Colors.white,
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
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const LoginScreen(),
          transitionsBuilder: (_, a, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: a, curve: Curves.easeInOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (r) => false,
      );
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
          backgroundColor: _PC.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _PC.navy900,
      extendBody: true,
      body: Stack(
        children: [
          // ── Layered background
          _BackgroundLayer(size: size),

          // ── Floating particles
          FloatingParticles(count: 18, color: _PC.teal),

          // ── Main scrollable content
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _heroFade,
                    child: SlideTransition(
                      position: _heroSlide,
                      child: _HeroSection(user: user, pulseAnim: _pulse),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _cardFade,
                    child: _buildBottomSheet(user),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: 4, onTap: _onNavTap),
    );
  }

  // ── Bottom "rising" glass sheet ──────────────────────────────────────────────

  Widget _buildBottomSheet(user) {
  final notifEnabled = ref.watch(notificationProvider);

  return Stack(
    children: [
      // Container putih utama dengan padding atas untuk beri ruang wave
      Container(
        margin: const EdgeInsets.only(top: 30),
        color: const Color(0xFFF4F7FB),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('PENGATURAN AKUN'),
                  const SizedBox(height: 14),
                  _buildSettingsCard(notifEnabled),
                  const SizedBox(height: 28),
                  _LogoutButton(onTap: _showKeluarDialog),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Activa — Digital Wellness v1.0.0',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.25),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ],
        ),
      ),

      // Wave di atas container putih
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: ClipPath(
          clipper: _WaveClipper(),
          child: Container(
            height: 60,
            color: const Color(0xFFF4F7FB),
          ),
        ),
      ),
    ],
  );
}

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black.withValues(alpha: 0.35),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
      ),
    );
  }

  // ── Settings Card ─────────────────────────────────────────────────────────────

  Widget _buildSettingsCard(bool notifEnabled) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          PremiumSettingItem(
            icon: Icons.person_outline_rounded,
            iconGradient: const [Color(0xFF00E5C8), Color(0xFF0099AA)],
            title: 'Data Diri',
            subtitle: 'Edit profil & informasi personal',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilScreen()),
            ),
          ),
          PremiumSettingToggle(
            icon: Icons.notifications_none_rounded,
            iconGradient: const [Color(0xFF4B9FFF), Color(0xFF1A5FD0)],
            title: 'Notifikasi',
            subtitle: 'Pengingat analisis harian',
            value: notifEnabled,
            onChanged: (v) => ref.read(notificationProvider.notifier).toggle(v),
          ),
          PremiumSettingItem(
            icon: Icons.file_download_outlined,
            iconGradient: const [Color(0xFFFFB347), Color(0xFFE08020)],
            title: 'Ekspor Data',
            subtitle: 'Unduh hasil analisis dan perkembangan',
            onTap: _showExportOptions,
          ),
          PremiumSettingItem(
            icon: Icons.chat_bubble_outline_rounded,
            iconGradient: const [Color(0xFF8B7FFF), Color(0xFF5B4FD0)],
            title: 'Kritik dan Saran',
            subtitle: 'Bagikan pengalaman penggunaan Activa',
            onTap: _launchFeedbackEmail,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // ── Dialogs & Actions ─────────────────────────────────────────────────────────

  void _showKeluarDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Keluar dari Akun?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1F3C),
          ),
        ),
        content: const Text(
          'Sesi kamu akan berakhir dan perlu masuk kembali nanti.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF7A8AA0),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Color(0xFF7A8AA0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B8A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Keluar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchFeedbackEmail() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: 'activ4aaaaa@gmail.com',
      query:
          'subject=${Uri.encodeComponent('Kritik dan Saran Pengguna ACTIVA')}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka aplikasi Email'),
            backgroundColor: Color(0xFFFF6B8A),
          ),
        );
      }
    }
  }

  // ── Export ────────────────────────────────────────────────────────────────────

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExportBottomSheet(onExport: _handleExport),
    );
  }

  Future<void> _handleExport(String format) async {
    final storage = ref.read(localStorageProvider);
    final token = await storage.getToken();
    if (token == null) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi berakhir, silakan login kembali')),
        );
      return;
    }

    if (kIsWeb) {
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.export}?format=$format&token=$token',
      );
      if (await canLaunchUrl(url))
        await launchUrl(url, mode: LaunchMode.externalApplication);
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Text('Mengunduh file $format...'),
            ],
          ),
          backgroundColor: _PC.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    try {
      final apiClient = ref.read(apiClientProvider);
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists())
          directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      final fileName = format == 'pdf'
          ? 'activa_report_${DateTime.now().millisecondsSinceEpoch}.pdf'
          : 'activa_data_${DateTime.now().millisecondsSinceEpoch}.csv';
      final savePath = '${directory!.path}/$fileName';
      await apiClient.download(
        ApiEndpoints.export,
        savePath,
        queryParams: {'format': format},
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Berhasil mengunduh: $fileName'),
              backgroundColor: _PC.teal,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'BUKA',
                textColor: Colors.white,
                onPressed: () => OpenFile.open(savePath),
              ),
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                e is DioException
                    ? (e.response?.data?['message'] ?? 'Gagal mengunduh')
                    : 'Gagal mengunduh file',
              ),
              backgroundColor: _PC.rose,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── Background Layer  ─────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _BackgroundLayer extends StatelessWidget {
  final Size size;
  const _BackgroundLayer({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Base gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_PC.navy900, _PC.navy800, Color(0xFF0A1525)],
              ),
            ),
          ),

          // Teal glow orb — top left
          Positioned(
            top: -80,
            left: -60,
            child: _GlowOrb(color: _PC.teal, size: 260, opacity: 0.12),
          ),

          // Blue glow orb — top right
          Positioned(
            top: 80,
            right: -80,
            child: _GlowOrb(color: _PC.blue, size: 200, opacity: 0.10),
          ),

          // Rose orb — mid
          Positioned(
            top: size.height * 0.28,
            left: size.width * 0.4,
            child: _GlowOrb(color: _PC.rose, size: 150, opacity: 0.07),
          ),

          // Abstract wave overlay
          Positioned(
            bottom: size.height * 0.38,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(size.width, 120),
              painter: _WavePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  const _GlowOrb({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _PC.teal.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 60);
    path.cubicTo(
      size.width * 0.25,
      20,
      size.width * 0.5,
      100,
      size.width * 0.75,
      40,
    );
    path.cubicTo(size.width * 0.88, 10, size.width, 50, size.width, 50);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════════════════════
// ── Hero Section  ─────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _HeroSection extends StatelessWidget {
  final dynamic user;
  final Animation<double> pulseAnim;

  const _HeroSection({required this.user, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'Pengguna';
    final email = user?.email ?? 'pengguna@email.com';
    final initials = user?.initials ?? '?';
    final age = user?.age?.toString() ?? '-';

    final eduToIndo = {
      'High School': 'SMA/SMK',
      'Bachelor': 'Sarjana',
      'Master': 'Magister',
      'PhD': 'Doktor',
    };
    final edu = user?.educationLevel != null
        ? (eduToIndo[user!.educationLevel] ?? user!.educationLevel)
        : '-';
    final region = user?.region ?? '-';

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
      child: Column(
        children: [
          // Avatar only (no mascot)
          FuturisticAvatar(initials: initials, pulseAnim: pulseAnim, size: 96),

          const SizedBox(height: 20),

          // Name
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),

          // Email
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Wellness badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: _PC.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _PC.teal.withValues(alpha: 0.25)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, color: _PC.teal, size: 13),
                SizedBox(width: 6),
                Text(
                  'Digital Wellness Explorer',
                  style: TextStyle(
                    color: _PC.teal,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Info chips — pakai IconData bukan emoji
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassmorphismChip(icon: Icons.cake_outlined, label: '$age Tahun'),
              const SizedBox(width: 10),
              GlassmorphismChip(icon: Icons.school_outlined, label: edu),
              const SizedBox(width: 10),
              GlassmorphismChip(
                icon: Icons.location_on_outlined,
                label: region,
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── Logout Button  ────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _LogoutButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                const Color(
                  0xFFFF6B8A,
                ).withValues(alpha: _pressed ? 0.15 : 0.08),
                const Color(
                  0xFFCC3060,
                ).withValues(alpha: _pressed ? 0.12 : 0.05),
              ],
            ),
            border: Border.all(
              color: const Color(
                0xFFFF6B8A,
              ).withValues(alpha: _pressed ? 0.4 : 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFFF6B8A,
                ).withValues(alpha: _pressed ? 0.15 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFFF6B8A), size: 20),
              SizedBox(width: 10),
              Text(
                'Keluar dari Akun',
                style: TextStyle(
                  color: Color(0xFFFF6B8A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── Export Bottom Sheet  ──────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _ExportBottomSheet extends StatelessWidget {
  final Future<void> Function(String) onExport;
  const _ExportBottomSheet({required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Ekspor Data Analisis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1F3C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih format file untuk mengunduh riwayat analisis kamu',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _ExportCard(
                  icon: Icons.picture_as_pdf_rounded,
                  gradient: const [Color(0xFFFF6B8A), Color(0xFFCC3060)],
                  label: 'Format PDF',
                  subtitle: 'Laporan Visual',
                  onTap: () {
                    Navigator.pop(context);
                    onExport('pdf');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ExportCard(
                  icon: Icons.table_chart_rounded,
                  gradient: const [Color(0xFF00E5C8), Color(0xFF0099AA)],
                  label: 'Format CSV',
                  subtitle: 'Data Mentah',
                  onTap: () {
                    Navigator.pop(context);
                    onExport('excel');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportCard({
    required this.icon,
    required this.gradient,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradient[0].withValues(alpha: 0.08),
              gradient[1].withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gradient[0].withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(
                color: gradient[0],
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: gradient[0].withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}