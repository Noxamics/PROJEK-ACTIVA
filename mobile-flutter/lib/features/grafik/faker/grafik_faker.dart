// lib/features/grafik/faker/grafik_faker.dart
//
// File ini hanya berisi model data & enum periode.
// Faker sudah dihapus — data sekarang dari API via grafik_provider.dart.

// ─────────────────────────────────────────────────────────────────────────────
// Enum periode
// ─────────────────────────────────────────────────────────────────────────────

enum GrafikPeriod { week, monthly, yearly }

extension GrafikPeriodExt on GrafikPeriod {
  /// Query param yang dikirim ke API: ?period=week|monthly|yearly
  String get apiParam => switch (this) {
        GrafikPeriod.week    => 'week',
        GrafikPeriod.monthly => 'monthly',
        GrafikPeriod.yearly  => 'yearly',
      };

  /// Label yang tampil di selector
  String get label => switch (this) {
        GrafikPeriod.week    => '7 Hari',
        GrafikPeriod.monthly => 'Bulanan',
        GrafikPeriod.yearly  => 'Tahunan',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Model: satu titik data pada chart
// ─────────────────────────────────────────────────────────────────────────────

/// Satu entry harian / mingguan / bulanan untuk semua chart.
/// Field nullable karena user mungkin belum mengisi kuesioner hari itu.
class GrafikEntry {
  /// Label sumbu-X (misal: 'Sen', 'M1', 'Jan')
  final String label;

  /// Tanggal entry (untuk tooltip atau debug)
  final String date;

  /// Skor dependensi digital 0–100. Null = tidak ada data.
  final double? dependenceScore;

  /// Kategori dependensi: 'rendah' | 'sedang' | 'tinggi'. Null = tidak ada data.
  final String? category;

  /// Rata-rata screen time dalam jam/hari (0–15). Null = tidak ada data.
  final double? deviceHours;

  /// Durasi media sosial dalam menit (0–500). Null = tidak ada data.
  final double? socialMediaMins;

  /// Durasi tidur dalam jam (0–12). Null = tidak ada data.
  final double? sleepHours;

  /// Apakah ada data (ml_result atau survey) di periode ini.
  final bool hasData;

  const GrafikEntry({
    required this.label,
    required this.date,
    this.dependenceScore,
    this.category,
    this.deviceHours,
    this.socialMediaMins,
    this.sleepHours,
    this.hasData = false,
  });

  factory GrafikEntry.fromJson(Map<String, dynamic> json) {
    return GrafikEntry(
      label:            json['label'] as String,
      date:             json['date'] as String,
      dependenceScore:  (json['dependence_score'] as num?)?.toDouble(),
      category:         json['category'] as String?,
      deviceHours:      (json['device_hours'] as num?)?.toDouble(),
      socialMediaMins:  (json['social_media_mins'] as num?)?.toDouble(),
      sleepHours:       (json['sleep_hours'] as num?)?.toDouble(),
      hasData:          json['has_data'] as bool? ?? false,
    );
  }
}

/// Agregat distribusi kategori dependensi untuk DonutChart.
class GrafikKategori {
  final int low;
  final int medium;
  final int high;

  const GrafikKategori({
    required this.low,
    required this.medium,
    required this.high,
  });

  factory GrafikKategori.fromJson(Map<String, dynamic> json) {
    return GrafikKategori(
      low:    json['low'] as int? ?? 0,
      medium: json['medium'] as int? ?? 0,
      high:   json['high'] as int? ?? 0,
    );
  }
}

/// Satu paket data lengkap untuk seluruh GrafikScreen.
class GrafikData {
  final List<GrafikEntry> entries;
  final GrafikKategori kategori;

  const GrafikData({required this.entries, required this.kategori});

  factory GrafikData.fromJson(Map<String, dynamic> json) {
    return GrafikData(
      entries:  (json['entries'] as List)
          .map((e) => GrafikEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      kategori: GrafikKategori.fromJson(json['kategori'] as Map<String, dynamic>),
    );
  }

  // ── Shortcut getters untuk widget ────────────────────────────────────────
  // Nilai null diganti 0 agar chart tidak crash (titik kosong tampil di 0)

  List<double> get dependenceValues =>
      entries.map((e) => e.dependenceScore ?? 0).toList();

  List<double> get deviceHourValues =>
      entries.map((e) => e.deviceHours ?? 0).toList();

  List<double> get socialMediaValues =>
      entries.map((e) => e.socialMediaMins ?? 0).toList();

  List<double> get sleepHourValues =>
      entries.map((e) => e.sleepHours ?? 0).toList();

  List<String> get labels =>
      entries.map((e) => e.label).toList();

  /// True jika semua entry tidak punya data (user belum pernah isi kuesioner)
  bool get isEmpty => entries.every((e) => !e.hasData);
}