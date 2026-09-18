import '../models/call_record.dart';
import 'api_client.dart';

class BackendHistoryService {
  final ApiClient _api;
  BackendHistoryService(this._api);

  Future<void> syncHistory({
    required String token,
    required List<CallRecord> records,
  }) async {
    await _api.request(
      method: 'POST',
      path: '/history/sync',
      token: token,
      body: {'records': records.map((r) => r.toJson()).toList()},
    );
  }

  Future<List<CallRecord>> fetchHistory({
    required String token,
    int limit = 200,
  }) async {
    final payload = await _api.request(
      method: 'GET',
      path: '/history?limit=$limit',
      token: token,
    );
    final recordsRaw = payload['records'];
    if (recordsRaw is! List) return const [];
    return recordsRaw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(CallRecord.fromJson)
        .toList();
  }

  Future<void> clearHistory({required String token}) async {
    await _api.request(method: 'DELETE', path: '/history', token: token);
  }

  Future<Map<String, dynamic>> fetchLatestAiAnalysis() =>
      _api.request(method: 'GET', path: '/assist/analysis/latest');

  Uri latestAiReportPdfUrl() =>
      _api.buildUri('/assist/analysis/latest/pdf');
}
