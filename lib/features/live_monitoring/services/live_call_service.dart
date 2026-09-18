import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/live_risk_scores.dart';
import 'aegis_agent_controller.dart';
import 'audio_watchdog_service.dart';
import 'guardian_sms_service.dart';
import 'live_call_evaluator.dart';
import 'live_call_session.dart';
import 'local_database_service.dart';
import 'local_phone_lookup.dart';

export '../models/live_risk_scores.dart';

class LiveCallService {
  final LiveCallSession _session = LiveCallSession();
  final AegisAgentController _agent = AegisAgentController();
  final LocalDatabaseService _db;
  late final GuardianSmsService _sms;
  late final AudioWatchdogService _watchdog;

  bool _started = false;
  String _callNumber = '';
  String _transcript = '';
  double _syntheticScore = 0.0;
  double _phoneScore = 0.0;

  void Function(LiveRiskScores)? _onRisk;
  void Function(AgentTacticalGuidance)? _onGuidance;

  LiveCallService({LocalDatabaseService? dbService})
      : _db = dbService ?? LocalDatabaseService() {
    _sms = GuardianSmsService(_db);
    _watchdog = AudioWatchdogService(
      stallThreshold: const Duration(milliseconds: 2400),
      heartbeatInterval: const Duration(milliseconds: 750),
      onRecoverAudio: _session.recoverAudio,
    );
  }

  bool get isStarted => _started;
  String get currentTranscript => _transcript;
  int get chunkCount => _session.chunkCount;
  String get activeCallNumber => _callNumber;
  AegisAgentController get agentController => _agent;
  AudioWatchdogService get watchdog => _watchdog;

  Future<void> start({
    required String callNumber,
    required void Function(LiveRiskScores) onRisk,
    required void Function(String) onError,
    void Function(AgentTacticalGuidance)? onGuidance,
    void Function(AudioWatchdogReport)? onWatchdogReport,
    void Function(int, int)? onAudioDebug,
  }) async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) throw Exception('Microphone permission denied.');
    _onRisk = onRisk;
    _onGuidance = onGuidance;
    _callNumber = callNumber;
    _agent.reset();
    _watchdog.start();
    if (onWatchdogReport != null) _watchdog.reportStream.listen(onWatchdogReport);
    _phoneScore = (await LocalPhoneLookup.lookup(callNumber)).threatScore;

    await _session.attachStreams(
      onHeartbeat: _watchdog.recordAudioHeartbeat,
      onSyntheticScore: (s) {
        _syntheticScore = s;
        _evaluateAndEmit();
      },
      onTranscript: (t) {
        if (t != _transcript) {
          _transcript = t;
          _evaluateAndEmit();
        }
      },
    );

    _started = true;
    _evaluateAndEmit();
  }

  void _evaluateAndEmit() {
    if (_onRisk == null) return;
    final (scores, threat) = LiveCallEvaluator.computeScores(
      transcript: _transcript,
      syntheticScore: _syntheticScore,
      phoneScore: _phoneScore,
    );
    _onRisk!(scores);
    final g = _agent.evaluate(
      transcript: _transcript,
      syntheticVoiceScore: _syntheticScore,
      phoneRiskScore: _phoneScore,
      intentRiskScore: scores.scamIntent,
      detectedKeywords: threat.detectedKeywords,
    );
    _onGuidance?.call(g);
    LiveCallEvaluator.dispatchActions(
      guidance: g,
      callNumber: _callNumber,
      sms: _sms,
      db: _db,
    );
  }

  void injectTestTranscript(String phrase) {
    _transcript = phrase;
    _evaluateAndEmit();
  }

  Future<void> stop() async {
    _started = false;
    _watchdog.stop();
    await _session.stop();
    _callNumber = '';
    _transcript = '';
    _syntheticScore = 0.0;
    _phoneScore = 0.0;
  }

  Future<void> dispose() async {
    await stop();
    _watchdog.dispose();
    _agent.dispose();
    await _session.dispose();
  }
}

final liveCallServiceProvider = Provider<LiveCallService>((ref) {
  final s = LiveCallService(dbService: ref.watch(localDatabaseProvider));
  ref.onDispose(s.dispose);
  return s;
});
