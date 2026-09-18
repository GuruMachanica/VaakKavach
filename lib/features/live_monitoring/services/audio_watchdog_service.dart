import 'dart:async';
import '../models/audio_watchdog_report.dart';

export '../models/audio_watchdog_report.dart';

/// Self-healing watchdog that monitors audio telemetry streams.
/// If chunks stop arriving for longer than [stallThreshold], it autonomously
/// fires recovery callbacks to revive the recording pipeline without dropping the call.
class AudioWatchdogService {
  final Duration stallThreshold;
  final Duration heartbeatInterval;
  final Future<bool> Function()? onRecoverAudio;

  Timer? _heartbeatTimer;
  DateTime _lastChunkTimestamp = DateTime.now();
  int _chunkCounter = 0;
  int _recoveryAttempts = 0;
  bool _isMonitoring = false;
  AudioHealthStatus _status = AudioHealthStatus.healthy;

  final StreamController<AudioWatchdogReport> _reportController =
      StreamController<AudioWatchdogReport>.broadcast();

  Stream<AudioWatchdogReport> get stream => _reportController.stream;
  Stream<AudioWatchdogReport> get reportStream => stream;
  AudioHealthStatus get currentStatus => _status;
  int get recoveryAttempts => _recoveryAttempts;
  bool get isMonitoring => _isMonitoring;
  void recordAudioHeartbeat() => recordChunk();

  AudioWatchdogService({
    this.stallThreshold = const Duration(milliseconds: 2200),
    this.heartbeatInterval = const Duration(milliseconds: 800),
    this.onRecoverAudio,
  });

  /// Starts monitoring the audio stream heartbeat.
  void start() {
    _isMonitoring = true;
    _recoveryAttempts = 0;
    _chunkCounter = 0;
    _lastChunkTimestamp = DateTime.now();
    _status = AudioHealthStatus.healthy;

    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) => _checkHealth());
    _emitReport('Audio watchdog initialized. Pipeline healthy.');
  }

  /// Called every time a valid PCM audio chunk or telemetry frame is received.
  void recordChunk() {
    _chunkCounter++;
    _lastChunkTimestamp = DateTime.now();

    if (_status == AudioHealthStatus.stalled ||
        _status == AudioHealthStatus.recovering) {
      _status = AudioHealthStatus.recovered;
      _emitReport('Audio stream self-healed and recovered successfully.');
      _status = AudioHealthStatus.healthy;
    }
  }

  /// Internal heartbeat check.
  Future<void> _checkHealth() async {
    if (!_isMonitoring) return;

    final now = DateTime.now();
    final elapsed = now.difference(_lastChunkTimestamp);

    if (elapsed > stallThreshold && _status != AudioHealthStatus.recovering) {
      _status = AudioHealthStatus.stalled;
      _recoveryAttempts++;
      _emitReport(
        'Stall detected: No audio received for ${elapsed.inMilliseconds}ms. Initiating self-healing recovery #$_recoveryAttempts...',
      );

      if (onRecoverAudio != null) {
        _status = AudioHealthStatus.recovering;
        try {
          final success = await onRecoverAudio!();
          if (success) {
            _lastChunkTimestamp = DateTime.now();
            _status = AudioHealthStatus.recovered;
            _emitReport('Self-healing reboot successful.');
            _status = AudioHealthStatus.healthy;
          } else {
            _status = AudioHealthStatus.stalled;
            _emitReport('Recovery attempt returned false. Will retry on next heartbeat.');
          }
        } catch (e) {
          _status = AudioHealthStatus.stalled;
          _emitReport('Recovery attempt encountered error: $e');
        }
      }
    } else if (elapsed > Duration(milliseconds: stallThreshold.inMilliseconds ~/ 2) &&
        _status == AudioHealthStatus.healthy) {
      _status = AudioHealthStatus.warning;
      _emitReport('Stream jitter warning: chunk latency elevated (${elapsed.inMilliseconds}ms).');
    }
  }

  void _emitReport(String message) {
    final now = DateTime.now();
    final elapsed = now.difference(_lastChunkTimestamp).inMilliseconds;
    final report = AudioWatchdogReport(
      status: _status,
      totalChunksReceived: _chunkCounter,
      millisecondsSinceLastChunk: elapsed,
      recoveryAttemptCount: _recoveryAttempts,
      message: message,
    );
    if (!_reportController.isClosed) {
      _reportController.add(report);
    }
  }

  /// Stops monitoring and cancels heartbeat timers.
  void stop() {
    _isMonitoring = false;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _status = AudioHealthStatus.healthy;
  }

  void dispose() {
    stop();
    _reportController.close();
  }
}
