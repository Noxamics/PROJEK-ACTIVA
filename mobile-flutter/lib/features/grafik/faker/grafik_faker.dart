// lib/features/grafik/faker/grafik_faker.dart
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │  GRAFIK FAKER                                                           │
// │  Dummy data generator untuk GrafikScreen selama masa development.       │
// │                                                                         │
// │  Cara pakai:                                                            │
// │    final data = GrafikFaker.generate(period: GrafikPeriod.week);        │
// │                                                                         │
// │  Cara ganti ke data asli:                                               │
// │    Cukup ganti pemanggilan GrafikFaker.generate() di grafik_provider    │
// │    dengan call ke GrafikService / AnalyticsRepository. Selama model     │
// │    GrafikData tetap sama, tidak ada perubahan di widget/screen.         │
// └─────────────────────────────────────────────────────────────────────────┘

import 'dart:math';

// ─────────────────────────────────────────────────────────────────────────────
// Enum periode yang tersedia
// ─────────────────────────────────────────────────────────────────────────────

enum GrafikPeriod { week, month, year }

// ─────────────────────────────────────────────────────────────────────────────
// Model: satu titik data pada chart
// ─────────────────────────────────────────────────────────────────────────────

/// Satu entry harian / mingguan / bulanan untuk semua chart.
class GrafikEntry {
  /// Label sumbu-X (misal: 'Sen', 'Sel', '1 Apr', 'Jan')
  final String label;

  /// Skor dependensi digital 0–100
  final double dependenceScore;

  /// Rata-rata screen time dalam jam/hari (0–15)
  final double deviceHours;

  /// Durasi media sosial dalam menit (0–500)
  final double socialMediaMins;

  /// Durasi tidur dalam jam (0–12)
  final double sleepHours;

  const GrafikEntry({
    required this.label,
    required this.dependenceScore,
    required this.deviceHours,
    required this.socialMediaMins,
    required this.sleepHours,
  });
}

/// Aggregat ringkasan distribusi kategori dependensi.
class GrafikKategori {
  /// Jumlah kuesioner dengan hasil Rendah
  final int low;

  /// Jumlah kuesioner dengan hasil Sedang
  final int medium;

  /// Jumlah kuesioner dengan hasil Tinggi
  final int high;

  const GrafikKategori({
    required this.low,
    required this.medium,
    required this.high,
  });
}

/// Satu paket data lengkap untuk seluruh GrafikScreen.
class GrafikData {
  final List<GrafikEntry> entries;
  final GrafikKategori kategori;

  const GrafikData({required this.entries, required this.kategori});

  // ── Shortcut getters untuk widget ────────────────────────────────────────

  List<double> get dependenceValues =>
      entries.map((e) => e.dependenceScore).toList();
  List<double> get deviceHourValues =>
      entries.map((e) => e.deviceHours).toList();
  List<double> get socialMediaValues =>
      entries.map((e) => e.socialMediaMins).toList();
  List<double> get sleepHourValues => entries.map((e) => e.sleepHours).toList();
  List<String> get labels => entries.map((e) => e.label).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Faker utama
// ─────────────────────────────────────────────────────────────────────────────

class GrafikFaker {
  GrafikFaker._(); // private constructor — pure static

  static final _rng = Random(
    42,
  ); // seed tetap → data konsisten antar hot-reload

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Hasilkan [GrafikData] dummy sesuai periode.
  /// Ganti method ini dengan service call saat backend sudah siap.
  static GrafikData generate({required GrafikPeriod period}) {
    return switch (period) {
      GrafikPeriod.week => _generateWeek(),
      GrafikPeriod.month => _generateMonth(),
      GrafikPeriod.year => _generateYear(),
    };
  }

  // ── Generators per periode ─────────────────────────────────────────────────

  static GrafikData _generateWeek() {
    const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    // Skor dependensi naik perlahan menuju weekend (orang lebih banyak main HP)
    final dependence = _smoothSeries(start: 38, end: 62, count: 7, noiseMax: 6);

    final deviceHours = _smoothSeries(
      start: 5.5,
      end: 8.5,
      count: 7,
      noiseMax: 1.2,
    );
    final socialMedia = _smoothSeries(
      start: 120,
      end: 280,
      count: 7,
      noiseMax: 40,
    );
    final sleep = _smoothSeries(start: 7.5, end: 5.8, count: 7, noiseMax: 0.8);

    final entries = List.generate(
      7,
      (i) => GrafikEntry(
        label: labels[i],
        dependenceScore: dependence[i],
        deviceHours: deviceHours[i],
        socialMediaMins: socialMedia[i],
        sleepHours: sleep[i],
      ),
    );

    return GrafikData(
      entries: entries,
      kategori: const GrafikKategori(low: 2, medium: 3, high: 2),
    );
  }

  static GrafikData _generateMonth() {
    // 4 minggu
    const labels = ['M1', 'M2', 'M3', 'M4'];

    final dependence = _smoothSeries(start: 42, end: 55, count: 4, noiseMax: 5);
    final deviceHours = _smoothSeries(
      start: 6.0,
      end: 7.5,
      count: 4,
      noiseMax: 0.8,
    );
    final socialMedia = _smoothSeries(
      start: 150,
      end: 230,
      count: 4,
      noiseMax: 30,
    );
    final sleep = _smoothSeries(start: 7.0, end: 6.2, count: 4, noiseMax: 0.5);

    final entries = List.generate(
      4,
      (i) => GrafikEntry(
        label: labels[i],
        dependenceScore: dependence[i],
        deviceHours: deviceHours[i],
        socialMediaMins: socialMedia[i],
        sleepHours: sleep[i],
      ),
    );

    return GrafikData(
      entries: entries,
      kategori: const GrafikKategori(low: 5, medium: 8, high: 3),
    );
  }

  static GrafikData _generateYear() {
    const labels = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    final dependence = _smoothSeries(start: 35, end: 58, count: 12, noiseMax: 4);
    final deviceHours = _smoothSeries(
      start: 5.8,
      end: 7.8,
      count: 12,
      noiseMax: 0.6,
    );
    final socialMedia = _smoothSeries(
      start: 130,
      end: 260,
      count: 12,
      noiseMax: 25,
    );
    final sleep = _smoothSeries(start: 7.5, end: 6.0, count: 12, noiseMax: 0.4);

    final entries = List.generate(
      12,
      (i) => GrafikEntry(
        label: labels[i],
        dependenceScore: dependence[i],
        deviceHours: deviceHours[i],
        socialMediaMins: socialMedia[i],
        sleepHours: sleep[i],
      ),
    );

    return GrafikData(
      entries: entries,
      kategori: const GrafikKategori(low: 45, medium: 60, high: 20),
    );
  }

  // ── Helper ─────────────────────────────────────────────────────────────────

  /// Buat series angka yang mengalir smooth dari [start] ke [end],
  /// ditambah noise acak ±[noiseMax] agar tidak kelihatan terlalu linear.
  static List<double> _smoothSeries({
    required double start,
    required double end,
    required int count,
    required double noiseMax,
  }) {
    if (count == 1) return [start];

    return List.generate(count, (i) {
      final t = i / (count - 1); // 0.0 → 1.0
      final base = start + (end - start) * t;
      final noise = (_rng.nextDouble() - 0.5) * 2 * noiseMax;
      return base + noise;
    });
  }
}
