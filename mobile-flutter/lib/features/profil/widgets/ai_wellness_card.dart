// widgets/ai_wellness_card.dart
//
// Premium AI Wellness Status Card — connected to real histori data.
// Shows: glowing mini-graph bars, wellness icon, dynamic insight text.
// Style: glassmorphism, floating, rounded corners, soft teal glow.

import 'package:flutter/material.dart';
import '../../hasil_prediksi/models/ml_result_model.dart';

class AiWellnessCard extends StatefulWidget {
  /// Recent histori items, sorted newest-first.
  /// Pass the full list from historiProvider — the card will take the last 7.
  final List<MlResultModel> items;

  const AiWellnessCard({super.key, required this.items});

  @override
  State<AiWellnessCard> createState() => _AiWellnessCardState();
}

class _AiWellnessCardState extends State<AiWellnessCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _barAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Compute data ────────────────────────────────────────────────────────────

  /// Ambil 7 data terbaru, reversed agar urutan kronologis (kiri = paling lama).
  List<MlResultModel> get _recent {
    final take = widget.items.length >= 7 ? 7 : widget.items.length;
    return widget.items.take(take).toList().reversed.toList();
  }

  /// Normalisasi skor ketergantungan jadi "wellness" (0..1).
  /// Skor 0 → wellness 1.0 (sempurna), skor 100 → wellness 0.0.
  /// Ditambah floor 0.08 agar bar tidak sepenuhnya hilang.
  List<double> get _bars {
    if (_recent.isEmpty) return List.filled(7, 0.15);
    return _recent.map((e) {
      final wellness = 1.0 - (e.digitalDependenceScore.clamp(0, 100) / 100);
      return wellness.clamp(0.08, 1.0);
    }).toList();
  }

  /// Label hari sesuai data (dari createdAt), atau placeholder.
  List<String> get _dayLabels {
    const dayMap = ['M', 'S', 'S', 'R', 'K', 'J', 'S'];
    if (_recent.isEmpty) return dayMap;
    return _recent.map((e) => dayMap[e.createdAt.weekday % 7]).toList();
  }

  /// Hitung persentase perubahan rata-rata skor wellness minggu ini vs sebelumnya.
  /// Positif = membaik, negatif = memburuk.
  double get _weeklyChange {
    if (widget.items.length < 2) return 0;

    // Ambil rata-rata skor dari 7 terbaru (minggu ini)
    final thisWeek = widget.items.take(7).toList();
    final avgThis = thisWeek.fold<double>(
          0,
          (s, e) => s + e.digitalDependenceScore,
        ) /
        thisWeek.length;

    // Ambil rata-rata skor dari 7 berikutnya (minggu lalu)
    if (widget.items.length <= 7) {
      // Tidak cukup data untuk bandingin
      return 0;
    }
    final lastWeek = widget.items.skip(7).take(7).toList();
    if (lastWeek.isEmpty) return 0;

    final avgLast = lastWeek.fold<double>(
          0,
          (s, e) => s + e.digitalDependenceScore,
        ) /
        lastWeek.length;

    if (avgLast == 0) return 0;
    // Perubahan negatif di skor = positif di wellness (membaik)
    return ((avgLast - avgThis) / avgLast * 100);
  }

  /// Generate insight text berdasarkan data terbaru.
  String get _insightText {
    if (widget.items.isEmpty) {
      return 'Isi kuesioner untuk melihat insight wellness-mu';
    }
    if (widget.items.length == 1) {
      return 'Data pertamamu sudah masuk! Terus pantau perkembanganmu';
    }

    final latest = widget.items.first;
    final change = _weeklyChange;

    if (change > 10) {
      return 'Perjalanan digitalmu semakin membaik! Pertahankan';
    } else if (change > 0) {
      return 'Perjalanan digitalmu mulai lebih stabil minggu ini';
    } else if (change > -10) {
      return 'Skor wellnessmu cukup stabil, tetap konsisten ya';
    } else {
      return 'Skor ketergantungan meningkat, coba kurangi screen time';
    }
  }

  /// Trend icon & color.
  ({IconData icon, Color color, String label}) get _trendInfo {
    final change = _weeklyChange;
    if (change > 0) {
      return (
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF00E5C8),
        label: '+${change.abs().toStringAsFixed(0)}% dari minggu lalu',
      );
    } else if (change < -1) {
      return (
        icon: Icons.trending_down_rounded,
        color: const Color(0xFFFF6B8A),
        label: '-${change.abs().toStringAsFixed(0)}% dari minggu lalu',
      );
    }
    return (
      icon: Icons.trending_flat_rounded,
      color: const Color(0xFF4B9FFF),
      label: 'Stabil dari minggu lalu',
    );
  }

  @override
  Widget build(BuildContext context) {
    final trend = _trendInfo;
    final hasData = widget.items.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0D1F3C).withValues(alpha: 0.92),
            const Color(0xFF091528).withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF00E5C8).withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5C8).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Mascot icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF00E5C8), Color(0xFF005588)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5C8).withValues(alpha: 0.35),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.spa_rounded, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Wellness Insight',
                      style: TextStyle(
                        color: Color(0xFF00E5C8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _insightText,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.90),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Mini graph
          _MiniGraph(
            bars: _bars,
            dayLabels: _dayLabels,
            anim: _barAnim,
            hasData: hasData,
          ),

          const SizedBox(height: 14),

          // Trend label
          if (hasData && widget.items.length > 7)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: trend.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trend.icon, color: trend.color, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        trend.label,
                        style: TextStyle(
                          color: trend.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else if (hasData)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B9FFF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF4B9FFF),
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${widget.items.length} data — butuh >7 untuk tren',
                        style: const TextStyle(
                          color: Color(0xFF4B9FFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Mini bar graph inside wellness card ────────────────────────────────────────

class _MiniGraph extends StatelessWidget {
  final List<double> bars;
  final List<String> dayLabels;
  final Animation<double> anim;
  final bool hasData;

  const _MiniGraph({
    required this.bars,
    required this.dayLabels,
    required this.anim,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    const barHeight = 52.0;
    const barW = 10.0;

    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        return SizedBox(
          height: barHeight + 22,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(bars.length, (i) {
              final h = barHeight * bars[i] * anim.value;
              final isLast = i == bars.length - 1;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: barW,
                    height: h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: !hasData
                            ? [
                                const Color(0xFF00E5C8).withValues(alpha: 0.15),
                                const Color(0xFF4B9FFF).withValues(alpha: 0.2),
                              ]
                            : isLast
                                ? [
                                    const Color(0xFF00E5C8),
                                    const Color(0xFF00FFE0),
                                  ]
                                : [
                                    const Color(0xFF00E5C8)
                                        .withValues(alpha: 0.3),
                                    const Color(0xFF4B9FFF)
                                        .withValues(alpha: 0.5),
                                  ],
                      ),
                      boxShadow: (isLast && hasData)
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00E5C8)
                                    .withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    i < dayLabels.length ? dayLabels[i] : '',
                    style: TextStyle(
                      color: (isLast && hasData)
                          ? const Color(0xFF00E5C8)
                          : Colors.white.withValues(alpha: 0.35),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
