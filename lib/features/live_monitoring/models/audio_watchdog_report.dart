enum AudioHealthStatus {
  healthy,
  warning,
  stalled,
  recovering,
  recovered,
}

class AudioWatchdogReport {
  final AudioHealthStatus status;
  final int totalChunksReceived;
  final int millisecondsSinceLastChunk;
  final int recoveryAttemptCount;
  final String message;

  const AudioWatchdogReport({
    required this.status,
    required this.totalChunksReceived,
    required this.millisecondsSinceLastChunk,
    required this.recoveryAttemptCount,
    required this.message,
  });
}
