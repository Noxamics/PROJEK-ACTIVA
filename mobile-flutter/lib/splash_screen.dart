import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// ─────────────────────────────────────────────────────────────
// Cara pakai:
//   home: const SplashScreen(),
// Setelah animasi selesai, navigasi ke halaman berikutnya
// dengan mengisi [onFinished] callback.
// ─────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  const SplashScreen({super.key, this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo scale + fade
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // Cincin berputar
  late final AnimationController _ring1Ctrl;
  late final AnimationController _ring2Ctrl;

  // Teks muncul
  late final AnimationController _textCtrl;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  // Dot loading
  late final AnimationController _dotCtrl;

  // Glow
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowScale;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    // ── Logo ──────────────────────────────────────────────
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // ── Cincin ────────────────────────────────────────────
    _ring1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _ring2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // ── Teks ──────────────────────────────────────────────
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    // ── Dot loading ───────────────────────────────────────
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // ── Glow ──────────────────────────────────────────────
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _glowScale = Tween<double>(
      begin: 0.8,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _glowOpacity = Tween<double>(
      begin: 0.0,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // ── Urutan animasi ────────────────────────────────────
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) widget.onFinished?.call(); // ← tambah mounted check
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _ring1Ctrl.dispose();
    _ring2Ctrl.dispose();
    _textCtrl.dispose();
    _dotCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo + Cincin ────────────────────────────
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow
                  AnimatedBuilder(
                    animation: _glowCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _glowOpacity.value,
                      child: Transform.scale(
                        scale: _glowScale.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0x4022C16E), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Cincin luar (searah jarum jam)
                  AnimatedBuilder(
                    animation: _ring1Ctrl,
                    builder: (_, __) => Transform.rotate(
                      angle: _ring1Ctrl.value * 2 * math.pi,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: CustomPaint(
                          painter: _ArcPainter(
                            color: const Color(0xFF22C16E),
                            strokeWidth: 2,
                            sweepFraction: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Cincin dalam (berlawanan jarum jam)
                  AnimatedBuilder(
                    animation: _ring2Ctrl,
                    builder: (_, __) => Transform.rotate(
                      angle: -_ring2Ctrl.value * 2 * math.pi,
                      child: SizedBox(
                        width: 128,
                        height: 128,
                        child: CustomPaint(
                          painter: _ArcPainter(
                            color: const Color(0xFF168477),
                            strokeWidth: 2,
                            sweepFraction: 0.45,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Logo Activa
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: SizedBox(
                          width: 75,
                          height: 75,
                          child: SvgPicture.asset(
                            'assets/logo/NewLogoEmblem2_fixed.svg',
                            width: 90,
                            height: 90,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── Judul ────────────────────────────────────
            FadeTransition(
              opacity: _textOpacity,
              child: SlideTransition(
                position: _textSlide,
                child: const Text(
                  'ACTIVA',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Memuat + dots ─────────────────────────────
            FadeTransition(
              opacity: _textOpacity,
              child: SlideTransition(
                position: _textSlide,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Memuat',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF22C16E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _dotCtrl,
                      builder: (_, __) => Row(
                        children: List.generate(3, (i) {
                          // Setiap dot pulse dengan delay berbeda
                          final delay = i / 3.0;
                          final t = (_dotCtrl.value - delay) % 1.0;
                          final scale = t < 0.5
                              ? 1.0 + t * 0.6
                              : 1.3 - (t - 0.5) * 0.6;
                          final opacity = t < 0.5
                              ? 0.3 + t * 1.4
                              : 1.0 - (t - 0.5) * 1.4;
                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Transform.scale(
                              scale: scale.clamp(1.0, 1.3),
                              child: Opacity(
                                opacity: opacity.clamp(0.3, 1.0),
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF22C16E),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Painter: Arc untuk cincin animasi
// ─────────────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double sweepFraction; // 0.0 – 1.0

  const _ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.sweepFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * sweepFraction,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => false;
}

// ─────────────────────────────────────────────────────────────
// Painter: Logo Activa (5 path dari SVG asli)
// viewBox asli: 1166.68 x 1188.36
// translate asli: (-56.9, -46.66)
// ─────────────────────────────────────────────────────────────
class _ActivaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Scale dari viewBox asli ke ukuran widget
    final scaleX = size.width / 1166.68;
    final scaleY = size.height / 1188.36;

    canvas.save();
    canvas.scale(scaleX, scaleY);
    // Terapkan translate dari SVG: translate(-56.9 -46.66)
    // artinya koordinat path sudah include offset, kita geser balik
    canvas.translate(-56.9, -46.66);

    _drawPath1(canvas);
    _drawPath2(canvas);
    _drawPath3(canvas);
    _drawPath4(canvas);
    _drawPath5(canvas);

    canvas.restore();
  }

  void _drawPath1(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF22C16E);
    final path = Path();
    path.moveTo(808.7, 611.28);
    path.lineTo(557.79, 611.28);
    path.cubicTo(566.44, 591.16, 578.14, 574.96, 588.2, 558.08);
    path.cubicTo(658.41, 440.19, 729.85, 323, 799.27, 204.67);
    path.cubicTo(827.49, 156.55, 857.42, 109.3, 881.94, 59);
    path.cubicTo(885.43, 51.85, 888.94, 46.57, 898.89, 46.62);
    path.cubicTo(987.46, 47.07, 1076.04, 46.88, 1167.89, 46.88);
    path.cubicTo(1083.82, 180.13, 997.25, 309.29, 910.65, 438.88);
    path.cubicTo(921.12, 446.88, 931.21, 446.41, 941.17, 446.39);
    path.lineTo(1158.85, 445.97);
    path.cubicTo(1164.7, 445.97, 1170.55, 445.97, 1181.54, 445.97);
    path.cubicTo(963.27, 713.24, 742.33, 972.87, 520.06, 1235);
    path.cubicTo(515.54, 1224.8, 519.47, 1219.36, 521.98, 1214.06);
    path.quadraticBezierTo(538.67, 1178.65, 555.82, 1143.43);
    path.cubicTo(605.74, 1040.92, 656, 938.52, 705.62, 835.86);
    path.cubicTo(739.77, 765.29, 773.21, 694.37, 806.9, 623.58);
    path.cubicTo(808.38, 620.47, 810.66, 617.41, 808.7, 611.28);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawPath2(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF1BC06A);
    final path = Path();
    path.moveTo(765.55, 46.87);
    path.cubicTo(747.81, 86.77, 731.32, 123.46, 715.14, 160.29);
    path.quadraticBezierTo(639.92, 331.45, 564.92, 502.71);
    path.cubicTo(550.63, 535.34, 536.26, 567.95, 522.67, 600.87);
    path.cubicTo(518.87, 610.07, 513.58, 613.59, 503.94, 613.47);
    path.cubicTo(476.62, 613.14, 449.23, 611.61, 422.03, 612.13);
    path.cubicTo(388.23, 612.77, 354.53, 609.97, 319.63, 611.91);
    path.cubicTo(318.98, 604.24, 322.25, 597.91, 324.9, 591.81);
    path.cubicTo(382.11, 459.39, 436, 325.59, 490.46, 192);
    path.cubicTo(507.26, 150.8, 523.32, 109.29, 539.46, 67.81);
    path.cubicTo(547.46, 47.3, 547.16, 47.16, 569.86, 47.12);
    path.quadraticBezierTo(658.16, 46.96, 746.46, 46.84);
    path.lineTo(765.55, 46.87);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawPath3(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF1CBF6A);
    final path = Path();
    path.moveTo(397.48, 910.58);
    path.cubicTo(379.72, 959.7, 358.24, 1007.32, 338.68, 1055.71);
    path.cubicTo(317.12, 1109.08, 295.13, 1162.28, 273.62, 1215.71);
    path.cubicTo(270.78, 1222.78, 268.53, 1228.3, 259.18, 1228.26);
    path.cubicTo(192.1, 1227.99, 125.02, 1228.11, 56.9, 1228.11);
    path.cubicTo(58.28, 1216.36, 64.67, 1207.52, 68.71, 1197.98);
    path.quadraticBezierTo(155.71, 992.19, 243.31, 786.65);
    path.quadraticBezierTo(261.75, 743.24, 279.82, 699.65);
    path.cubicTo(282.48, 693.21, 285.1, 688.56, 293.56, 688.65);
    path.cubicTo(356.56, 689.32, 419.56, 689.56, 482.56, 689.97);
    path.cubicTo(483.1, 689.97, 483.64, 690.42, 485.69, 691.33);
    path.cubicTo(482, 709.54, 473, 726.1, 466, 743.28);
    path.cubicTo(447.23, 789.41, 428, 835.34, 409.12, 881.42);
    path.cubicTo(408.29, 883.42, 408.98, 886.11, 408.96, 888.47);
    path.cubicTo(409.56, 898.13, 401.4, 903.25, 397.48, 910.58);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawPath4(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF20BF6C);
    final path = Path();
    path.moveTo(1223.58, 1224.65);
    path.cubicTo(1216.11, 1229.28, 1210.58, 1228.07, 1205.41, 1228.08);
    path.cubicTo(1144.77, 1228.22, 1084.12, 1228.08, 1023.48, 1228.44);
    path.cubicTo(1013.48, 1228.51, 1007.66, 1226.44, 1003.39, 1216.14);
    path.quadraticBezierTo(937.87, 1057.32, 871, 899.07);
    path.cubicTo(866.81, 889.16, 867.83, 883.42, 874.72, 875.75);
    path.cubicTo(913.96, 832.03, 952.72, 787.84, 988.78, 741.43);
    path.cubicTo(992.69, 736.43, 996.22, 731.07, 1001.4, 723.8);
    path.cubicTo(1075.71, 891.69, 1151.64, 1056.78, 1223.58, 1224.65);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawPath5(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF168477);
    final path = Path();
    path.moveTo(397.48, 910.58);
    path.cubicTo(398.85, 901.92, 401.84, 894.11, 409.0, 888.47);
    path.cubicTo(414.25, 887.57, 419.49, 885.9, 424.74, 885.88);
    path.quadraticBezierTo(530.8, 885.46, 636.88, 885.54);
    path.cubicTo(641.36, 885.54, 646.62, 884.12, 649.72, 889.26);
    path.cubicTo(653.28, 895.16, 649.45, 904.71, 642.39, 906.07);
    path.cubicTo(637.21, 907.07, 631.74, 906.71, 626.39, 906.71);
    path.quadraticBezierTo(522.96, 906.56, 419.59, 906.37);
    path.cubicTo(412.0, 906.36, 404.0, 904.78, 397.48, 910.58);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ActivaLogoPainter old) => false;
}
