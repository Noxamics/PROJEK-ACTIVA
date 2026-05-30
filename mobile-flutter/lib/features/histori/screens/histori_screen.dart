import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/histori_provider.dart';
import '../models/analisis_data.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../profil/screens/profil_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../../hasil_prediksi/screens/hasil_prediksi_screen.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Design Tokens
// ─────────────────────────────────────────────────────────────────────────────

class _Colors {
  static const navy900 = Color(0xFF050D1A); // [CHANGED] sama seperti profil
  static const navy800 = Color(0xFF091528); // [CHANGED] sama seperti profil
  static const navy700 = Color(0xFF111D42);
  static const teal = Color(0xFF00E5C8); // [CHANGED] sama seperti profil
  static const tealDim = Color(0xFF0099AA); // [CHANGED] sama seperti profil
  static const blue = Color(0xFF4B9FFF); // [CHANGED] sama seperti profil
  static const purple = Color(0xFF8B6BF0);
  static const amber = Color(0xFFFFBF40);
  static const green = Color(0xFF40E8A0);
  static const red = Color(
    0xFFFF4D6A,
  ); // [NEW] warna merah untuk kategori tinggi
  static const glass = Color(0x18FFFFFF);
  static const glassBorder = Color(0x30FFFFFF);
  static const timelineLine = Color(0xFF1E2E60);
}

class _TextStyles {
  static const pageTitle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: -0.5,
  );
  static const pageSubtitle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0x99FFFFFF),
    letterSpacing: 0.3,
  );
  static const cardTitle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static const cardMeta = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Color(0x80FFFFFF),
    letterSpacing: 0.2,
  );
  static const insightText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xCCFFFFFF),
    height: 1.5,
  );
  static const scoreNumber = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );
  static const monthLabel = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Color(0x70FFFFFF),
    letterSpacing: 1.4,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class HistoriScreen extends ConsumerStatefulWidget {
  const HistoriScreen({super.key});

  @override
  ConsumerState<HistoriScreen> createState() => _HistoriScreenState();
}

class _HistoriScreenState extends ConsumerState<HistoriScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgPulseCtrl;
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _bgPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _bgPulseCtrl.dispose();
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historiProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _Colors.navy900,
      body: Stack(
        children: [
          // ── Layered background (sama seperti profil screen) ─────────────────
          _BackgroundLayer(size: size),

          // ── Pulsing bg glow ─────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _bgPulseCtrl,
            builder: (_, __) => Positioned(
              top: -80 + (_bgPulseCtrl.value * 20),
              right: -60,
              child: _GlowOrb(
                size: 280,
                color: _Colors.teal,
                opacity: 0.07 + _bgPulseCtrl.value * 0.04,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _bgPulseCtrl,
            builder: (_, __) => Positioned(
              bottom: 120,
              left: -80,
              child: _GlowOrb(
                size: 240,
                color: _Colors.purple,
                opacity: 0.06 + _bgPulseCtrl.value * 0.03,
              ),
            ),
          ),

          // ── Main content (tanpa bottom nav) ────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                FadeTransition(opacity: _headerFade, child: _buildHeader()),
                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final state = ref.watch(historiProvider);
    final hasFilter =
        state.sortOption != HistoriSortOption.terbaru ||
        state.categoryFilter != HistoriCategoryFilter.semua;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _GlassChip(
              padding: const EdgeInsets.all(10),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Histori Analisis', style: _TextStyles.pageTitle),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _TealDot(),
                    const SizedBox(width: 5),
                    const Text(
                      'Perjalanan digital wellness kamu',
                      style: _TextStyles.pageSubtitle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showFilterSheet(),
            child: _GlassChip(
              glowColor: hasFilter ? _Colors.teal : null,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color: hasFilter ? _Colors.teal : Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: hasFilter ? _Colors.teal : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(HistoriState state) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                color: _Colors.teal,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat perjalananmu...',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (state.status == HistoriStatus.error) {
      return _buildErrorState(state.errorMessage ?? 'Terjadi kesalahan');
    }

    if (state.isEmpty) {
      return _buildEmptyState();
    }

    final grouped = state.groupedByMonth;

    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _MascotIcon(mood: _MascotMood.neutral, size: 64),
            const SizedBox(height: 16),
            Text(
              'Tidak ada hasil yang sesuai',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white.withOpacity(0.8),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba ubah filter',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _Colors.teal,
      backgroundColor: _Colors.navy700,
      onRefresh: () => ref.read(historiProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...grouped.entries.toList().asMap().entries.map((mapEntry) {
              final idx = mapEntry.key;
              final entry = mapEntry.value;
              return _TimelineMonthSection(
                monthLabel: entry.key,
                items: entry.value
                    .map((item) => AnalisisDataConverter.fromMlResult(item))
                    .toList(),
                sectionIndex: idx,
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              _GlowOrb(size: 120, color: _Colors.teal, opacity: 0.1),
              const _MascotIcon(mood: _MascotMood.happy, size: 72),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada perjalanan',
            style: TextStyle(
              fontFamily: 'Nunito',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'digital yang tercatat ✨',
            style: TextStyle(
              fontFamily: 'Nunito',
              color: Colors.white.withOpacity(0.6),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_Colors.teal, _Colors.tealDim],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _Colors.teal.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Text(
                'Mulai Analisis',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error State ─────────────────────────────────────────────────────────────

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.1),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Colors.redAccent,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => ref.read(historiProvider.notifier).refresh(),
            child: _GlassChip(
              glowColor: _Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: _Colors.teal,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Sheet ────────────────────────────────────────────────────────────

  void _showFilterSheet() {
    final state = ref.read(historiProvider);
    final notifier = ref.read(historiProvider.notifier);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(state: state, notifier: notifier),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background Layer — sama seperti ProfilScreen
// ─────────────────────────────────────────────────────────────────────────────

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
                colors: [_Colors.navy900, _Colors.navy800, Color(0xFF0A1525)],
              ),
            ),
          ),

          // Teal glow orb — top left
          Positioned(
            top: -80,
            left: -60,
            child: _GlowOrb(color: _Colors.teal, size: 260, opacity: 0.12),
          ),

          // Blue glow orb — top right
          Positioned(
            top: 80,
            right: -80,
            child: _GlowOrb(color: _Colors.blue, size: 200, opacity: 0.10),
          ),

          // Purple orb — mid
          Positioned(
            top: size.height * 0.28,
            left: size.width * 0.4,
            child: _GlowOrb(color: _Colors.purple, size: 150, opacity: 0.07),
          ),

          // Wave overlay
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

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _Colors.teal.withOpacity(0.04)
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

// ─────────────────────────────────────────────────────────────────────────────
// Glow Orb — RadialGradient seperti profil screen
// ─────────────────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _GlowOrb({
    required this.size,
    required this.color,
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
          colors: [color.withOpacity(opacity), color.withOpacity(0)],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline Month Section
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineMonthSection extends StatelessWidget {
  final String monthLabel;
  final List<AnalisisData> items;
  final int sectionIndex;

  const _TimelineMonthSection({
    required this.monthLabel,
    required this.items,
    required this.sectionIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 28, bottom: 12),
          child: Text(monthLabel.toUpperCase(), style: _TextStyles.monthLabel),
        ),
        ...items.asMap().entries.map(
          (e) => _TimelineItem(
            data: e.value,
            index: e.key,
            isLast: e.key == items.length - 1,
            globalIndex: sectionIndex * 10 + e.key,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline Item
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineItem extends StatefulWidget {
  final AnalisisData data;
  final int index;
  final bool isLast;
  final int globalIndex;

  const _TimelineItem({
    required this.data,
    required this.index,
    required this.isLast,
    required this.globalIndex,
  });

  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 80 * widget.globalIndex), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    _TimelineDot(category: widget.data.kategori),
                    if (!widget.isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                _categoryColor(
                                  widget.data.kategori,
                                ).withOpacity(0.6),
                                _Colors.timelineLine,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _pressed = true),
                    onTapUp: (_) => setState(() => _pressed = false),
                    onTapCancel: () => setState(() => _pressed = false),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HasilPrediksiScreen(
                            result: widget.data.originalResult,
                          ),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      transform: Matrix4.identity()
                        ..translate(0.0, _pressed ? 2.0 : 0.0)
                        ..scale(_pressed ? 0.98 : 1.0),
                      child: _AnalysisCard(data: widget.data),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glowing Timeline Dot
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineDot extends StatefulWidget {
  final String category;
  const _TimelineDot({required this.category});

  @override
  State<_TimelineDot> createState() => _TimelineDotState();
}

class _TimelineDotState extends State<_TimelineDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(widget.category);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 20 + _ctrl.value * 8,
              height: 20 + _ctrl.value * 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.08 + _ctrl.value * 0.07),
              ),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Analysis Card
// ─────────────────────────────────────────────────────────────────────────────

class _AnalysisCard extends StatelessWidget {
  final AnalisisData data;
  const _AnalysisCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(data.kategori);
    final mood = _moodFromKategori(data.kategori);
    final insight = _insightFromKategori(data.kategori);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.04),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.14),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: catColor.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      catColor.withOpacity(0.8),
                      catColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data.title, style: _TextStyles.cardTitle),
                              const SizedBox(height: 3),
                              Text(
                                data.relativeTime,
                                style: _TextStyles.cardMeta,
                              ),
                            ],
                          ),
                        ),
                        _MascotIcon(mood: mood, size: 38),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ScoreOrb(score: data.score, color: catColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _CategoryBadge(
                                label: data.kategori,
                                color: catColor,
                              ),
                              const SizedBox(height: 6),
                              _StatusBadge(label: data.statusWellness),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: catColor.withOpacity(0.15),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 10,
                            color: catColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(insight, style: _TextStyles.insightText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Score Orb
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreOrb extends StatelessWidget {
  final double score;
  final Color color;
  const _ScoreOrb({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(56, 56),
            painter: _RingPainter(progress: score / 100, color: color),
          ),
          Text(
            score.toStringAsFixed(0),
            style: _TextStyles.scoreNumber.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    paint.color = Colors.white.withOpacity(0.08);
    canvas.drawCircle(center, radius, paint);

    paint.color = color;
    paint.shader = SweepGradient(
      colors: [color.withOpacity(0.4), color],
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi * progress,
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8)],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mascot Icon
// ─────────────────────────────────────────────────────────────────────────────

enum _MascotMood { happy, attentive, tired, neutral }

class _MascotIcon extends StatefulWidget {
  final _MascotMood mood;
  final double size;
  const _MascotIcon({required this.mood, required this.size});

  @override
  State<_MascotIcon> createState() => _MascotIconState();
}

class _MascotIconState extends State<_MascotIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _float = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emoji = switch (widget.mood) {
      _MascotMood.happy => '😊',
      _MascotMood.attentive => '🤔',
      _MascotMood.tired => '😴',
      _MascotMood.neutral => '🙂',
    };

    return AnimatedBuilder(
      animation: _float,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, -3 + _float.value * 6),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: TextStyle(fontSize: widget.size * 0.45)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass Chip
// ─────────────────────────────────────────────────────────────────────────────

class _GlassChip extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? glowColor;
  const _GlassChip({
    required this.child,
    required this.padding,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _Colors.glass,
            border: Border.all(
              color: glowColor?.withOpacity(0.4) ?? _Colors.glassBorder,
              width: 1,
            ),
            boxShadow: glowColor != null
                ? [
                    BoxShadow(
                      color: glowColor!.withOpacity(0.2),
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Teal pulsing dot
// ─────────────────────────────────────────────────────────────────────────────

class _TealDot extends StatefulWidget {
  @override
  State<_TealDot> createState() => _TealDotState();
}

class _TealDotState extends State<_TealDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _Colors.teal.withOpacity(0.5 + _ctrl.value * 0.5),
          boxShadow: [
            BoxShadow(color: _Colors.teal.withOpacity(0.5), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FilterSheet extends ConsumerWidget {
  final HistoriState state;
  final HistoriNotifier notifier;
  const _FilterSheet({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveState = ref.watch(historiProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          decoration: BoxDecoration(
            color: _Colors.navy700.withOpacity(0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Urutkan & Filter',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              const Text('KATEGORI', style: _TextStyles.monthLabel),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: HistoriCategoryFilter.values.map((cat) {
                  final active = liveState.categoryFilter == cat;
                  return _filterChip(
                    label: _categoryLabel(cat),
                    active: active,
                    onTap: () => notifier.setCategoryFilter(cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('URUTKAN', style: _TextStyles.monthLabel),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: HistoriSortOption.values.map((opt) {
                  final active = liveState.sortOption == opt;
                  return _filterChip(
                    label: _sortLabel(opt),
                    active: active,
                    onTap: () => notifier.setSortOption(opt),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: active ? _Colors.teal.withOpacity(0.18) : _Colors.glass,
          border: Border.all(
            color: active ? _Colors.teal.withOpacity(0.7) : _Colors.glassBorder,
            width: active ? 1.5 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _Colors.teal.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? _Colors.teal : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  String _categoryLabel(HistoriCategoryFilter cat) => switch (cat) {
    HistoriCategoryFilter.semua => 'Semua',
    HistoriCategoryFilter.rendah => 'Rendah',
    HistoriCategoryFilter.sedang => 'Sedang',
    HistoriCategoryFilter.tinggi => 'Tinggi',
    HistoriCategoryFilter.mingguIni => 'Minggu Ini',
  };

  String _sortLabel(HistoriSortOption opt) => switch (opt) {
    HistoriSortOption.terbaru => 'Terbaru',
    HistoriSortOption.terlama => 'Terlama',
    HistoriSortOption.skorTertinggi => 'Skor Tertinggi',
    HistoriSortOption.skorTerendah => 'Skor Terendah',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

// [CHANGED] 'tinggi' sekarang merah, bukan pink
Color _categoryColor(String kategori) => switch (kategori.toLowerCase()) {
  'rendah' => _Colors.green,
  'sedang' => _Colors.amber,
  'tinggi' => _Colors.red,
  _ => _Colors.teal,
};

_MascotMood _moodFromKategori(String kategori) =>
    switch (kategori.toLowerCase()) {
      'rendah' => _MascotMood.happy,
      'sedang' => _MascotMood.attentive,
      'tinggi' => _MascotMood.tired,
      _ => _MascotMood.neutral,
    };

String _insightFromKategori(String kategori) => switch (kategori
    .toLowerCase()) {
  'rendah' =>
    'Kondisi digitalmu mulai lebih stabil. Pertahankan keseimbangan ini! 🌿',
  'sedang' =>
    'Screen time malam hari masih cukup tinggi. Coba jadwalkan waktu offline.',
  'tinggi' =>
    'Perlu perhatian ekstra. Tidur & istirahat digitalmu butuh penyesuaian. 💙',
  _ => 'Terus pantau perkembangan wellness digitalmu bersama Activa.',
};

extension AnalisisDataUI on AnalisisData {
  String get statusWellness => switch (kategori.toLowerCase()) {
    'rendah' => 'Hidup Sehat',
    'sedang' => 'Mulai Stabil',
    'tinggi' => 'Perlu Perhatian',
    _ => 'Dalam Pemantauan',
  };
}
