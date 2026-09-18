import 'package:sqflite/sqflite.dart';

extension LocalDatabaseQueries on Database {
  Future<List<Map<String, String>>> loadBlockedCallers() async {
    final rows = await query('blocked_callers', orderBy: 'created_at DESC');
    return rows
        .map((r) => {
              'phone_number': r['phone_number']?.toString() ?? '',
              'reason': r['reason']?.toString() ?? '',
              'created_at': r['created_at']?.toString() ?? '',
            })
        .toList();
  }

  Future<bool> isNumberBlocked(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final rows = await query(
      'blocked_callers',
      where: 'phone_number = ?',
      whereArgs: [clean],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> blockCaller(String phoneNumber, String reason) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    await insert(
      'blocked_callers',
      {
        'phone_number': clean,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> unblockCaller(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    await delete(
      'blocked_callers',
      where: 'phone_number = ?',
      whereArgs: [clean],
    );
  }

  Future<void> logThreatAudit({
    required String id,
    required String callId,
    required String threatType,
    required String description,
  }) async {
    await insert(
      'threat_audit_logs',
      {
        'id': id,
        'call_id': callId,
        'threat_type': threatType,
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> loadThreatAudits() async {
    return await query('threat_audit_logs', orderBy: 'timestamp DESC');
  }

  Future<void> logEvent(String type, String message) async {
    await insert('app_events', {
      'type': type,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> loadGuardianContacts() async =>
      await query('guardian_contacts', orderBy: 'name ASC');

  Future<void> saveGuardianContact({
    required String id,
    required String name,
    required String phone,
    required String email,
    bool isActive = true,
  }) async {
    await insert(
      'guardian_contacts',
      {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'is_active': isActive ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteGuardianContact(String id) async =>
      await delete('guardian_contacts', where: 'id = ?', whereArgs: [id]);

  Future<void> toggleGuardianActive(String id, bool isActive) async {
    await update(
      'guardian_contacts',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

