import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../faker/grafik_faker.dart';

final grafikServiceProvider = Provider<GrafikService>((ref) {
  final client = ref.watch(apiClientProvider);
  return GrafikService(client);
});

class GrafikService {
  final ApiClient _client;

  GrafikService(this._client);

  /// Fetch history records from database and aggregate based on selected period
  Future<GrafikData> getGrafikData(GrafikPeriod period) async {
    final int days = switch (period) {
      GrafikPeriod.week => 7,
      GrafikPeriod.month => 30,
      GrafikPeriod.year => 365,
    };

    try {
      final response = await _client.get(
        ApiEndpoints.analyticsHistory,
        queryParams: {'days': days},
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;
      final records = data['records'] as List<dynamic>;

      return _parseAndAggregate(records, period);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  GrafikData _parseAndAggregate(List<dynamic> records, GrafikPeriod period) {
    if (records.isEmpty) {
      return const GrafikData(
        entries: [],
        kategori: GrafikKategori(low: 0, medium: 0, high: 0),
      );
    }

    // Count categories
    int lowCount = 0;
    int mediumCount = 0;
    int highCount = 0;

    for (var rec in records) {
      final cat = (rec['category'] as String? ?? 'rendah').toLowerCase();
      if (cat == 'rendah') {
        lowCount++;
      } else if (cat == 'sedang') {
        mediumCount++;
      } else if (cat == 'tinggi') {
        highCount++;
      }
    }

    final kategori = GrafikKategori(low: lowCount, medium: mediumCount, high: highCount);
    final List<GrafikEntry> entries = [];

    if (period == GrafikPeriod.week) {
      // Group by date (YYYY-MM-DD) to merge duplicates if any, then average
      final Map<String, List<Map<String, dynamic>>> groupedByDate = {};
      for (var rec in records) {
        final dateStr = rec['date'] as String;
        groupedByDate.putIfAbsent(dateStr, () => []).add(Map<String, dynamic>.from(rec as Map));
      }

      final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      final now = DateTime.now();

      for (int i = 6; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i));
        final yearStr = targetDate.year.toString().padLeft(4, '0');
        final monthStr = targetDate.month.toString().padLeft(2, '0');
        final dayStr = targetDate.day.toString().padLeft(2, '0');
        final dateStr = '$yearStr-$monthStr-$dayStr';

        final dayRecords = groupedByDate[dateStr] ?? [];
        final label = dayNames[targetDate.weekday - 1];

        if (dayRecords.isEmpty) {
          entries.add(GrafikEntry(
            label: label,
            dependenceScore: 0.0,
            deviceHours: 0.0,
            socialMediaMins: 0.0,
            sleepHours: 0.0,
          ));
          continue;
        }

        double avgDep = 0;
        double avgDevice = 0;
        double avgSocial = 0;
        double avgSleep = 0;

        for (var r in dayRecords) {
          avgDep += (r['dependence_score'] as num? ?? 0).toDouble();
          avgDevice += (r['device_hours'] as num? ?? 0).toDouble();
          avgSocial += (r['social_media_mins'] as num? ?? 0).toDouble();
          avgSleep += (r['sleep_hours'] as num? ?? 0).toDouble();
        }

        avgDep /= dayRecords.length;
        avgDevice /= dayRecords.length;
        avgSocial /= dayRecords.length;
        avgSleep /= dayRecords.length;

        entries.add(GrafikEntry(
          label: label,
          dependenceScore: avgDep,
          deviceHours: avgDevice,
          socialMediaMins: avgSocial,
          sleepHours: avgSleep,
        ));
      }
    } else if (period == GrafikPeriod.month) {
      // Group last 30 days into 4 relative weeks: M1, M2, M3, M4 based on relative days
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);

      final List<Map<String, dynamic>> w1 = [];
      final List<Map<String, dynamic>> w2 = [];
      final List<Map<String, dynamic>> w3 = [];
      final List<Map<String, dynamic>> w4 = [];

      for (var rec in records) {
        final dateStr = rec['date'] as String;
        final date = DateTime.tryParse(dateStr);
        if (date == null) continue;

        final diff = todayMidnight.difference(DateTime(date.year, date.month, date.day)).inDays;
        if (diff <= 7) {
          w4.add(Map<String, dynamic>.from(rec as Map));
        } else if (diff <= 14) {
          w3.add(Map<String, dynamic>.from(rec as Map));
        } else if (diff <= 21) {
          w2.add(Map<String, dynamic>.from(rec as Map));
        } else {
          w1.add(Map<String, dynamic>.from(rec as Map));
        }
      }

      final weeks = [
        {'label': 'M1', 'records': w1},
        {'label': 'M2', 'records': w2},
        {'label': 'M3', 'records': w3},
        {'label': 'M4', 'records': w4},
      ];

      for (var wk in weeks) {
        final label = wk['label'] as String;
        final wkRecords = wk['records'] as List<Map<String, dynamic>>;

        if (wkRecords.isEmpty) {
          entries.add(GrafikEntry(
            label: label,
            dependenceScore: 0.0,
            deviceHours: 0.0,
            socialMediaMins: 0.0,
            sleepHours: 0.0,
          ));
          continue;
        }

        double avgDep = 0;
        double avgDevice = 0;
        double avgSocial = 0;
        double avgSleep = 0;

        for (var r in wkRecords) {
          avgDep += (r['dependence_score'] as num? ?? 0).toDouble();
          avgDevice += (r['device_hours'] as num? ?? 0).toDouble();
          avgSocial += (r['social_media_mins'] as num? ?? 0).toDouble();
          avgSleep += (r['sleep_hours'] as num? ?? 0).toDouble();
        }

        avgDep /= wkRecords.length;
        avgDevice /= wkRecords.length;
        avgSocial /= wkRecords.length;
        avgSleep /= wkRecords.length;

        entries.add(GrafikEntry(
          label: label,
          dependenceScore: avgDep,
          deviceHours: avgDevice,
          socialMediaMins: avgSocial,
          sleepHours: avgSleep,
        ));
      }
    } else if (period == GrafikPeriod.year) {
      // Group rolling 12 months (e.g. current month - 11 down to current month)
      final Map<int, List<Map<String, dynamic>>> groupedByMonth = {};
      for (var rec in records) {
        final dateStr = rec['date'] as String;
        final date = DateTime.tryParse(dateStr);
        if (date == null) continue;
        groupedByMonth.putIfAbsent(date.month, () => []).add(Map<String, dynamic>.from(rec as Map));
      }

      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];

      final now = DateTime.now();
      for (int i = 11; i >= 0; i--) {
        final targetDate = DateTime(now.year, now.month - i, 1);
        final monthNum = targetDate.month;
        final label = monthNames[monthNum - 1];

        final mRecords = groupedByMonth[monthNum] ?? [];

        if (mRecords.isEmpty) {
          entries.add(GrafikEntry(
            label: label,
            dependenceScore: 0.0,
            deviceHours: 0.0,
            socialMediaMins: 0.0,
            sleepHours: 0.0,
          ));
          continue;
        }

        double avgDep = 0;
        double avgDevice = 0;
        double avgSocial = 0;
        double avgSleep = 0;

        for (var r in mRecords) {
          avgDep += (r['dependence_score'] as num? ?? 0).toDouble();
          avgDevice += (r['device_hours'] as num? ?? 0).toDouble();
          avgSocial += (r['social_media_mins'] as num? ?? 0).toDouble();
          avgSleep += (r['sleep_hours'] as num? ?? 0).toDouble();
        }

        avgDep /= mRecords.length;
        avgDevice /= mRecords.length;
        avgSocial /= mRecords.length;
        avgSleep /= mRecords.length;

        entries.add(GrafikEntry(
          label: label,
          dependenceScore: avgDep,
          deviceHours: avgDevice,
          socialMediaMins: avgSocial,
          sleepHours: avgSleep,
        ));
      }
    }

    return GrafikData(entries: entries, kategori: kategori);
  }

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    switch (e.response?.statusCode) {
      case 401:
        return 'Sesi habis. Silakan login ulang.';
      case 404:
        return 'Data grafik belum tersedia.';
      case 500:
        return 'Server sedang bermasalah. Coba lagi nanti.';
      default:
        if (e.type == DioExceptionType.connectionError) {
          return 'Tidak bisa terhubung ke server.';
        }
        return 'Error: ${e.message} \nStatus: ${e.response?.statusCode}\nResponse: ${e.response?.data}';
    }
  }
}
