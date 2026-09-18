import '../models/call_record.dart';

enum FilterPeriod { today, sevenDays }

class HistoryState {
  final List<CallRecord> records;
  final String searchQuery;
  final FilterPeriod filterPeriod;
  final bool isSyncing;
  final String? syncError;

  const HistoryState({
    this.records = const [],
    this.searchQuery = '',
    this.filterPeriod = FilterPeriod.sevenDays,
    this.isSyncing = false,
    this.syncError,
  });

  HistoryState copyWith({
    List<CallRecord>? records,
    String? searchQuery,
    FilterPeriod? filterPeriod,
    bool? isSyncing,
    String? syncError,
    bool clearSyncError = false,
  }) {
    return HistoryState(
      records: records ?? this.records,
      searchQuery: searchQuery ?? this.searchQuery,
      filterPeriod: filterPeriod ?? this.filterPeriod,
      isSyncing: isSyncing ?? this.isSyncing,
      syncError: clearSyncError ? null : (syncError ?? this.syncError),
    );
  }

  List<CallRecord> get filteredRecords {
    final now = DateTime.now();
    final cutoff = switch (filterPeriod) {
      FilterPeriod.today => DateTime(now.year, now.month, now.day),
      FilterPeriod.sevenDays => now.subtract(const Duration(days: 7)),
    };

    return records.where((r) {
      final afterCutoff = !r.callTime.isBefore(cutoff);
      if (!afterCutoff) return false;
      if (searchQuery.isEmpty) return true;
      final q = searchQuery.toLowerCase();
      return r.callerName.toLowerCase().contains(q) ||
          r.phoneNumber.toLowerCase().contains(q);
    }).toList()..sort((a, b) => b.callTime.compareTo(a.callTime));
  }

  int get recentActivityCount {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return records.where((r) => !r.callTime.isBefore(cutoff)).length;
  }

  int get todayScanned {
    final today = DateTime.now();
    return records
        .where(
          (r) =>
              r.callTime.year == today.year &&
              r.callTime.month == today.month &&
              r.callTime.day == today.day,
        )
        .length;
  }

  int get suspiciousCalls =>
      records.where((r) => r.riskScore >= 35 && r.riskScore < 65).length;

  int get blockedThreatsToday {
    final today = DateTime.now();
    return records
        .where(
          (r) =>
              r.callTime.year == today.year &&
              r.callTime.month == today.month &&
              r.callTime.day == today.day &&
              r.riskScore >= 65,
        )
        .length;
  }
}
