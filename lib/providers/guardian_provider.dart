import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/guardian_sms_service.dart';
import '../services/local_database_service.dart';

class GuardianContact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final bool isActive;

  const GuardianContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.isActive = true,
  });

  factory GuardianContact.fromMap(Map<String, dynamic> map) {
    return GuardianContact(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }
}

class GuardianNotifier extends AsyncNotifier<List<GuardianContact>> {
  @override
  Future<List<GuardianContact>> build() async {
    return _fetch();
  }

  Future<List<GuardianContact>> _fetch() async {
    final db = ref.read(localDatabaseProvider);
    final rows = await db.loadGuardianContacts();
    return rows.map(GuardianContact.fromMap).toList();
  }

  Future<void> addGuardian({
    required String name,
    required String phone,
    String email = '',
  }) async {
    final db = ref.read(localDatabaseProvider);
    final id = 'guardian_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    await db.saveGuardianContact(
      id: id,
      name: name,
      phone: phone,
      email: email,
      isActive: true,
    );
    state = AsyncData(await _fetch());
  }

  Future<void> deleteGuardian(String id) async {
    final db = ref.read(localDatabaseProvider);
    await db.deleteGuardianContact(id);
    state = AsyncData(await _fetch());
  }

  Future<void> toggleGuardian(String id, bool active) async {
    final db = ref.read(localDatabaseProvider);
    await db.toggleGuardianActive(id, active);
    state = AsyncData(await _fetch());
  }

  Future<GuardianSmsResult> sendTestAlert(String targetPhone) async {
    final smsService = ref.read(guardianSmsServiceProvider);
    return await smsService.broadcastEmergencyAlert(
      suspectNumber: targetPhone,
      threatType: 'Manual Test Broadcast',
      threatScore: 0.99,
    );
  }
}

final guardianProvider =
    AsyncNotifierProvider<GuardianNotifier, List<GuardianContact>>(
  GuardianNotifier.new,
);
