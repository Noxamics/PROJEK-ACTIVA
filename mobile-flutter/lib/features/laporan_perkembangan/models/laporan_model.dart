class LaporanInsights {
  final String digitalDependence;
  final String screenTime;
  final String socialMedia;
  final String sleep;
  final String stress;

  const LaporanInsights({
    required this.digitalDependence,
    required this.screenTime,
    required this.socialMedia,
    required this.sleep,
    required this.stress,
  });

  factory LaporanInsights.fromJson(Map<String, dynamic> j) => LaporanInsights(
    digitalDependence: j['digital_dependence'] ?? '-',
    screenTime: j['screen_time'] ?? '-',
    socialMedia: j['social_media'] ?? '-',
    sleep: j['sleep'] ?? '-',
    stress: j['stress'] ?? '-',
  );
}

class LaporanModel {
  final String status; // membaik | memburuk | stabil
  final double scorePct; // % perubahan (bisa negatif)
  final double thisWeekAvg;
  final double lastWeekAvg;
  final LaporanInsights insights;
  final List<String> causes;
  final List<String> recommendations;

  const LaporanModel({
    required this.status,
    required this.scorePct,
    required this.thisWeekAvg,
    required this.lastWeekAvg,
    required this.insights,
    required this.causes,
    required this.recommendations,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> j) {
    final d = j['data'] as Map<String, dynamic>;
    return LaporanModel(
      status: d['status'] ?? 'stabil',
      scorePct: (d['score_pct'] ?? 0).toDouble(),
      thisWeekAvg: (d['this_week_avg'] ?? 0).toDouble(),
      lastWeekAvg: (d['last_week_avg'] ?? 0).toDouble(),
      insights: LaporanInsights.fromJson(d['insights'] ?? {}),
      causes: List<String>.from(d['causes'] ?? []),
      recommendations: List<String>.from(d['recommendation'] ?? []),
    );
  }
}
