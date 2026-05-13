import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../services/dashboard_service.dart';
import '../../histori/providers/histori_provider.dart';

// ── Streak Model ─────────────────────────────────────────────────────────────

class StreakInfo {
  final int count;
  final String message;
  final int lastFilledDaysAgo;

  StreakInfo({
    required this.count,
    required this.message,
    required this.lastFilledDaysAgo,
  });
}

// ── State ──────────────────────────────────────────────────────────────────────

enum DashboardStatus { initial, loading, success, error }

class DashboardState {
  final DashboardStatus status;
  final AnalyticsModel? analytics;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.analytics,
    this.errorMessage,
  });

  bool get isLoading => status == DashboardStatus.loading;
  bool get hasData => analytics != null;

  DashboardState copyWith({
    DashboardStatus? status,
    AnalyticsModel? analytics,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      analytics: analytics ?? this.analytics,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardService _service;

  DashboardNotifier(this._service) : super(const DashboardState()) {
    // Auto-fetch saat pertama dibuka
    fetchAnalytics();
  }

  // ── Fetch analytics ────────────────────────────────────────────────────────
  Future<void> fetchAnalytics({bool useMock = true}) async {
    state = state.copyWith(status: DashboardStatus.loading, errorMessage: null);
    try {
      // Ganti getMockAnalytics() → getAnalytics() saat backend sudah siap
      final data = useMock
          ? await _service.getMockAnalytics()
          : await _service.getAnalytics();
      state = state.copyWith(status: DashboardStatus.success, analytics: data);
    } catch (e) {
      state = state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Refresh ────────────────────────────────────────────────────────────────
  Future<void> refresh() => fetchAnalytics();
}

// ── Provider ───────────────────────────────────────────────────────────────────

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      final service = ref.watch(dashboardServiceProvider);
      return DashboardNotifier(service);
    });

/// Shortcut — ambil data analytics langsung
final analyticsProvider = Provider<AnalyticsModel?>((ref) {
  return ref.watch(dashboardProvider).analytics;
});

/// Shortcut — Hitung streak pengisian kuesioner
final streakProvider = Provider<StreakInfo>((ref) {
  final historiItems = ref.watch(historiProvider).items;
  
  if (historiItems.isEmpty) {
    return StreakInfo(
      count: 0, 
      message: 'Mulai perjalanan sehatmu hari ini!', 
      lastFilledDaysAgo: -1,
    );
  }

  // Ambil tanggal unik (di-normalisasi ke jam 00:00)
  final dates = historiItems.map((item) {
    final d = item.createdAt;
    return DateTime(d.year, d.month, d.day);
  }).toSet().toList();

  // Urutkan dari yang terbaru
  dates.sort((a, b) => b.compareTo(a));

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final latestDate = dates.first;
  final diff = today.difference(latestDate).inDays;

  // Jika terakhir isi lebih dari 1 hari yang lalu (hari ini/kemarin tidak isi)
  if (diff > 1) {
    return StreakInfo(
      count: 0,
      message: 'Terakhir isi $diff hari yang lalu',
      lastFilledDaysAgo: diff,
    );
  }

  // Hitung streak berturut-turut ke belakang
  int streak = 1;
  for (int i = 0; i < dates.length - 1; i++) {
    if (dates[i].difference(dates[i+1]).inDays == 1) {
      streak++;
    } else {
      break;
    }
  }

  return StreakInfo(
    count: streak,
    message: streak > 1 
        ? '$streak hari konsisten: kamu rutin memantau kesehatan digitalmu'
        : 'Baru saja dimulai: teruskan kebiasaan baikmu!',
    lastFilledDaysAgo: diff,
  );
});
