import 'dart:async';
import 'local_audio_service.dart';
import 'microphone_recorder_service.dart';
import 'native_audio_bridge.dart';
import 'speech_dictation_service.dart';

class LiveCallSession {
  final MicrophoneRecorderService mic = MicrophoneRecorderService();
  final SpeechDictationService speech = SpeechDictationService();
  StreamSubscription? _audioSub;
  StreamSubscription? _nativeSub;
  int sampleRate = 16000;
  int chunkCount = 0;

  Future<void> attachStreams({
    required void Function() onHeartbeat,
    required void Function(double synthetic) onSyntheticScore,
    required void Function(String transcript) onTranscript,
  }) async {
    final nativeOk = await NativeAudioBridge.isAvailable();
    if (nativeOk) {
      await NativeAudioBridge.start(sampleRate: sampleRate);
      _nativeSub = NativeAudioBridge.spectralFlatnessStream.listen((f) {
        onSyntheticScore((1.0 - (f * 1.6)).clamp(0.0, 1.0));
        onHeartbeat();
      });
    }

    sampleRate = await mic.start();
    _audioSub = mic.stream.listen((frame) {
      chunkCount++;
      onHeartbeat();
      if (!nativeOk) {
        final f = LocalAudioService.estimateSpectralFlatness(frame);
        onSyntheticScore((1.0 - (f * 1.6)).clamp(0.0, 1.0));
      }
    });

    await speech.start(onResult: onTranscript);
  }

  Future<bool> recoverAudio() async {
    try {
      if (await NativeAudioBridge.isAvailable()) {
        if (await NativeAudioBridge.reboot(sampleRate: sampleRate)) return true;
      }
      await mic.stop();
      sampleRate = await mic.start();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    await speech.stop();
    await mic.stop();
    await NativeAudioBridge.stop();
    await _audioSub?.cancel();
    await _nativeSub?.cancel();
    _audioSub = null;
    _nativeSub = null;
    chunkCount = 0;
  }

  Future<void> dispose() async {
    await stop();
    await mic.dispose();
  }
}
