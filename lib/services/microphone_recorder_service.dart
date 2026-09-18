import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';

class MicrophoneRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final StreamController<Uint8List> _chunks =
      StreamController<Uint8List>.broadcast();

  Stream<Uint8List> get stream => _chunks.stream;

  Future<int> start() async {
    final sampleRates = [16000, 44100, 48000];
    Object? lastError;

    for (final sampleRate in sampleRates) {
      try {
        await _recorder.startRecorder(
          codec: Codec.pcm16,
          sampleRate: sampleRate,
          numChannels: 1,
          bitRate: sampleRate,
          bufferSize: 8192,
          toStream: _chunks.sink,
        );
        await _recorder.setSubscriptionDuration(
          const Duration(milliseconds: 200),
        );
        return sampleRate;
      } catch (error) {
        lastError = error;
        try {
          await _recorder.stopRecorder();
        } catch (_) {}
      }
    }
    throw Exception('Unable to start microphone recorder: $lastError');
  }

  Future<void> stop() async {
    try {
      await _recorder.stopRecorder();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await stop();
    try {
      await _recorder.closeRecorder();
    } catch (_) {}
    await _chunks.close();
  }
}
