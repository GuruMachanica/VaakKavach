import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_record.dart';
import '../models/history_state.dart';
import '../services/backend_service.dart';
import '../services/local_database_service.dart';
import 'auth_provider.dart';

export '../models/history_state.dart';

class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    Future.microtask(_hydrate);
    return const HistoryState();
  }

  Future<void> _hydrate() async {
    final local = await ref.read(localDatabaseProvider).loadCallRecords();
    if (!ref.mounted) return;
    state = state.copyWith(records: local);
    await _fetchRemote();
  }

  Future<void> _replaceLocalCache(List<CallRecord> records) async {
    final localDb = ref.read(localDatabaseProvider);
    await localDb.clearCallRecords();
    for (final record in records) {
      await localDb.insertCallRecord(record);
    }
  }

  Future<void> _fetchRemote() async {
    await ref.read(authProvider.notifier).ensureSessionValid();
    final auth = ref.read(authProvider);
    final token = auth.accessToken;
    if (token.isEmpty || token == 'LOCAL_EDGE_OFFLINE_TOKEN') return;

    try {
      final remote = await ref
          .read(backendServiceProvider)
          .fetchHistory(token: token);
      if (!ref.mounted) return;

      if (remote.isNotEmpty) {
        await _replaceLocalCache(remote);
        if (!ref.mounted) return;
        state = state.copyWith(records: remote, clearSyncError: true);
        return;
      }

      if (state.records.isNotEmpty) {
        await ref
            .read(backendServiceProvider)
            .syncHistory(token: token, records: state.records);
      }
      if (!ref.mounted) return;
      state = state.copyWith(clearSyncError: true);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(syncError: e.toString());
    }
  }

  Future<void> _sync() async {
    await ref.read(authProvider.notifier).ensureSessionValid();
    final token = ref.read(authProvider).accessToken;
    if (token.isEmpty || token == 'LOCAL_EDGE_OFFLINE_TOKEN') return;

    state = state.copyWith(isSyncing: true, clearSyncError: true);
    try {
      await ref
          .read(backendServiceProvider)
          .syncHistory(token: token, records: state.records);
      if (!ref.mounted) return;
      state = state.copyWith(isSyncing: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isSyncing: false, syncError: e.toString());
    }
  }

  Future<void> setSearch(String q) async {
    state = state.copyWith(searchQuery: q);
  }

  Future<void> setFilter(FilterPeriod p) async {
    state = state.copyWith(filterPeriod: p);
  }

  Future<void> addRecord(CallRecord r) async {
    await ref.read(localDatabaseProvider).insertCallRecord(r);
    state = state.copyWith(records: [r, ...state.records]);
    await _sync();
  }

  Future<void> clearAll() async {
    await ref.read(localDatabaseProvider).clearCallRecords();
    state = state.copyWith(records: []);
    await ref.read(authProvider.notifier).ensureSessionValid();
    final auth = ref.read(authProvider);
    if (auth.accessToken.isEmpty ||
        auth.accessToken == 'LOCAL_EDGE_OFFLINE_TOKEN') {
      return;
    }
    try {
      await ref
          .read(backendServiceProvider)
          .clearHistory(token: auth.accessToken);
      if (!ref.mounted) return;
      state = state.copyWith(clearSyncError: true);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(syncError: e.toString());
    }
  }

  void clearSyncError() => state = state.copyWith(clearSyncError: true);
}

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(
  HistoryNotifier.new,
);
