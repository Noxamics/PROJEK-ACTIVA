import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../hasil_prediksi/models/ml_result_model.dart';
import '../services/histori_service.dart';
import '../../auth/providers/auth_provider.dart';

// ── State ──────────────────────────────────────────────────────────────────────

enum HistoriStatus { initial, loading, success, empty, error }

enum HistoriSortOption { terbaru, terlama, skorTertinggi, skorTerendah }

// [NEW] Enum kategori filter — menggantikan chips baris atas di screen
enum HistoriCategoryFilter { semua, rendah, sedang, tinggi, mingguIni }

class HistoriState {
  final HistoriStatus status;
  final List<MlResultModel> items;
  final String? errorMessage;
  final HistoriSortOption sortOption;
  final HistoriCategoryFilter categoryFilter; // [NEW]

  const HistoriState({
    this.status = HistoriStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.sortOption = HistoriSortOption.terbaru,
    this.categoryFilter = HistoriCategoryFilter.semua, // [NEW]
  });

  bool get isLoading => status == HistoriStatus.loading;
  bool get isEmpty => status == HistoriStatus.empty || items.isEmpty;

  HistoriState copyWith({
    HistoriStatus? status,
    List<MlResultModel>? items,
    String? errorMessage,
    HistoriSortOption? sortOption,
    HistoriCategoryFilter? categoryFilter, // [NEW]
  }) {
    return HistoriState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      sortOption: sortOption ?? this.sortOption,
      categoryFilter: categoryFilter ?? this.categoryFilter, // [NEW]
    );
  }

  // ── Group by bulan untuk tampilan list ────────────────────────────────────
  Map<String, List<MlResultModel>> get groupedByMonth {
    const monthNames = [
      '',
      'JANUARI',
      'FEBRUARI',
      'MARET',
      'APRIL',
      'MEI',
      'JUNI',
      'JULI',
      'AGUSTUS',
      'SEPTEMBER',
      'OKTOBER',
      'NOVEMBER',
      'DESEMBER',
    ];

    final Map<String, List<MlResultModel>> grouped = {};

    var filteredItems = List<MlResultModel>.from(items);

    // [NEW] Filter berdasarkan kategori
    if (categoryFilter != HistoriCategoryFilter.semua) {
      filteredItems = filteredItems.where((item) {
        final cat = item.category.toLowerCase();
        switch (categoryFilter) {
          case HistoriCategoryFilter.rendah:
            return cat == 'rendah' || cat == 'low';
          case HistoriCategoryFilter.sedang:
            return cat == 'sedang' || cat == 'moderate';
          case HistoriCategoryFilter.tinggi:
            return cat == 'tinggi' || cat == 'high';
          case HistoriCategoryFilter.mingguIni:
            final weekAgo = DateTime.now().subtract(const Duration(days: 7));
            return item.createdAt.isAfter(weekAgo);
          case HistoriCategoryFilter.semua:
            return true;
        }
      }).toList();
    }

    // Sort
    filteredItems.sort((a, b) {
      switch (sortOption) {
        case HistoriSortOption.terbaru:
          return b.createdAt.compareTo(a.createdAt);
        case HistoriSortOption.terlama:
          return a.createdAt.compareTo(b.createdAt);
        case HistoriSortOption.skorTertinggi:
          return b.digitalDependenceScore.compareTo(a.digitalDependenceScore);
        case HistoriSortOption.skorTerendah:
          return a.digitalDependenceScore.compareTo(b.digitalDependenceScore);
      }
    });

    for (final item in filteredItems) {
      final key = '${monthNames[item.createdAt.month]} ${item.createdAt.year}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped;
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class HistoriNotifier extends StateNotifier<HistoriState> {
  final HistoriService _service;

  HistoriNotifier(this._service, [String? currentUserId])
    : super(const HistoriState()) {
    fetch();
  }

  Future<void> fetch({bool useMock = false}) async {
    state = state.copyWith(status: HistoriStatus.loading, errorMessage: null);
    try {
      final items = useMock
          ? await _service.getMockHistory()
          : await _service.getHistory();

      state = state.copyWith(
        status: items.isEmpty ? HistoriStatus.empty : HistoriStatus.success,
        items: items,
      );
    } catch (e) {
      state = state.copyWith(
        status: HistoriStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() => fetch();

  void setSortOption(HistoriSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  // [NEW] Set filter kategori
  void setCategoryFilter(HistoriCategoryFilter filter) {
    state = state.copyWith(categoryFilter: filter);
  }

  void addItem(MlResultModel result) {
    state = state.copyWith(
      status: HistoriStatus.success,
      items: [result, ...state.items],
    );
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────

final historiProvider = StateNotifierProvider<HistoriNotifier, HistoriState>((
  ref,
) {
  final service = ref.watch(historiServiceProvider);
  final user = ref.watch(currentUserProvider);
  return HistoriNotifier(service, user?.id);
});

final hasPerkembanganProvider = Provider<bool>((ref) {
  final items = ref.watch(historiProvider).items;
  if (items.length < 2) return false;
  return items[0].digitalDependenceScore < items[1].digitalDependenceScore;
});

final dependenceChangeProvider = Provider<double>((ref) {
  final items = ref.watch(historiProvider).items;
  if (items.length < 2) return 0.0;
  final latest = items[0].digitalDependenceScore;
  final prev = items[1].digitalDependenceScore;
  if (prev == 0) return 0.0;
  return ((latest - prev) / prev) * 100;
});

const int kWeeklyDataMinimum = 7;

final hasWeeklyDataProvider = Provider<bool>((ref) {
  return ref.watch(historiProvider).items.length >= kWeeklyDataMinimum;
});

final weeklyStatsProvider =
    Provider<({double screenTime, double sleepHours, int dataCount})>((ref) {
      final items = ref.watch(historiProvider).items;
      if (items.isEmpty) {
        return (screenTime: 0.0, sleepHours: 0.0, dataCount: 0);
      }
      final recent = items.take(kWeeklyDataMinimum).toList();
      final avgScreen =
          recent.map((e) => e.screenTime).reduce((a, b) => a + b) /
          recent.length;
      final avgSleep =
          recent.map((e) => e.sleepHours).reduce((a, b) => a + b) /
          recent.length;
      return (
        screenTime: avgScreen,
        sleepHours: avgSleep,
        dataCount: recent.length,
      );
    });

final dependencyDistributionProvider =
    Provider<({int low, int medium, int high, int total})>((ref) {
      final items = ref.watch(historiProvider).items;
      if (items.isEmpty) return (low: 0, medium: 0, high: 0, total: 0);

      int countLow = 0, countMedium = 0, countHigh = 0;
      for (final item in items) {
        final cat = item.category.toLowerCase();
        if (cat == 'tinggi' || cat == 'high') {
          countHigh++;
        } else if (cat == 'sedang' || cat == 'moderate') {
          countMedium++;
        } else {
          countLow++;
        }
      }
      return (
        low: countLow,
        medium: countMedium,
        high: countHigh,
        total: items.length,
      );
    });
