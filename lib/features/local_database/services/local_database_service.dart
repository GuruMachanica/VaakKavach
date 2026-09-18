import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../models/call_record.dart';
import '../models/risk_level.dart';
import 'local_database_queries.dart';
import 'local_database_schema.dart';

export 'local_database_queries.dart';
export 'local_database_schema.dart';

class LocalDatabaseService {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await LocalDatabaseSchema.initDatabase();
    return _db!;
  }

  // ── Call Records ─────────────────────────────────────────────────────────────
  Future<List<CallRecord>> loadCallRecords() async {
    final db = await database;
    final rows = await db.query('call_records', orderBy: 'call_time DESC');
    return rows.map((row) {
      final level = RiskLevel.values.firstWhere(
        (e) => e.name == (row['risk_level']?.toString() ?? 'safe'),
        orElse: () => RiskLevel.safe,
      );
      return CallRecord(
        id: row['id']?.toString() ?? '',
        callerName: row['caller_name']?.toString() ?? '',
        phoneNumber: row['phone_number']?.toString() ?? '',
        callTime: DateTime.tryParse(row['call_time']?.toString() ?? '') ??
            DateTime.now(),
        riskLevel: level,
        riskScore: (row['risk_score'] as int?) ?? 0,
        syntheticScore: (row['synthetic_score'] as int?) ?? 0,
        intentScore: (row['intent_score'] as int?) ?? 0,
        isSuspended: (row['is_suspended'] as int? ?? 0) == 1,
        avatarAsset: row['avatar_asset']?.toString(),
      );
    }).toList();
  }

  Future<void> insertCallRecord(CallRecord record) async {
    final db = await database;
    await db.insert(
      'call_records',
      {
        'id': record.id,
        'caller_name': record.callerName,
        'phone_number': record.phoneNumber,
        'call_time': record.callTime.toIso8601String(),
        'risk_level': record.riskLevel.name,
        'risk_score': record.riskScore,
        'synthetic_score': record.syntheticScore,
        'intent_score': record.intentScore,
        'is_suspended': record.isSuspended ? 1 : 0,
        'avatar_asset': record.avatarAsset,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearCallRecords() async {
    final db = await database;
    await db.delete('call_records');
  }

  // ── Blocked Callers ──────────────────────────────────────────────────────────
  Future<List<Map<String, String>>> loadBlockedCallers() async =>
      (await database).loadBlockedCallers();

  Future<bool> isNumberBlocked(String phoneNumber) async =>
      (await database).isNumberBlocked(phoneNumber);

  Future<void> blockCaller(String phoneNumber, String reason) async =>
      (await database).blockCaller(phoneNumber, reason);

  Future<void> unblockCaller(String phoneNumber) async =>
      (await database).unblockCaller(phoneNumber);

  // ── Guardian Contacts ────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> loadGuardianContacts() async =>
      (await database).loadGuardianContacts();

  Future<void> saveGuardianContact({
    required String id,
    required String name,
    required String phone,
    required String email,
    bool isActive = true,
  }) async =>
      (await database).saveGuardianContact(
        id: id,
        name: name,
        phone: phone,
        email: email,
        isActive: isActive,
      );

  Future<void> deleteGuardianContact(String id) async =>
      (await database).deleteGuardianContact(id);

  Future<void> toggleGuardianActive(String id, bool isActive) async =>
      (await database).toggleGuardianActive(id, isActive);


  // ── Threat Audit Logs & Events ───────────────────────────────────────────────
  Future<void> logThreatAudit({
    required String id,
    required String callId,
    required String threatType,
    required String description,
  }) async =>
      (await database).logThreatAudit(
        id: id,
        callId: callId,
        threatType: threatType,
        description: description,
      );

  Future<List<Map<String, dynamic>>> loadThreatAudits() async =>
      (await database).loadThreatAudits();

  Future<void> logEvent(String type, String message) async =>
      (await database).logEvent(type, message);
}

final localDatabaseProvider = Provider<LocalDatabaseService>((ref) {
  return LocalDatabaseService();
});
