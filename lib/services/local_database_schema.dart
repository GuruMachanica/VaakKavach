import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseSchema {
  static Future<Database> initDatabase() async {
    final isTestEnv = Platform.environment.containsKey('FLUTTER_TEST');
    final dbPath = isTestEnv
        ? inMemoryDatabasePath
        : join(await getDatabasesPath(), 'aegis_local.db');
    return await openDatabase(
      dbPath,
      version: 2,
      singleInstance: !isTestEnv,
      onCreate: (db, version) async {
        await createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS blocked_callers(
              phone_number TEXT PRIMARY KEY,
              reason TEXT,
              created_at TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS guardian_contacts(
              id TEXT PRIMARY KEY,
              name TEXT,
              phone TEXT,
              email TEXT,
              is_active INTEGER
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS threat_audit_logs(
              id TEXT PRIMARY KEY,
              call_id TEXT,
              threat_type TEXT,
              description TEXT,
              timestamp TEXT
            )
          ''');
        }
      },
    );
  }

  static Future<void> createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS call_records(
        id TEXT PRIMARY KEY,
        caller_name TEXT,
        phone_number TEXT,
        call_time TEXT,
        risk_level TEXT,
        risk_score INTEGER,
        synthetic_score INTEGER,
        intent_score INTEGER,
        is_suspended INTEGER,
        avatar_asset TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        message TEXT,
        created_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS blocked_callers(
        phone_number TEXT PRIMARY KEY,
        reason TEXT,
        created_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS guardian_contacts(
        id TEXT PRIMARY KEY,
        name TEXT,
        phone TEXT,
        email TEXT,
        is_active INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS threat_audit_logs(
        id TEXT PRIMARY KEY,
        call_id TEXT,
        threat_type TEXT,
        description TEXT,
        timestamp TEXT
      )
    ''');
  }
}
