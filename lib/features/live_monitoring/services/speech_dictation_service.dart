import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechDictationService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  Timer? _restartTimer;
  bool _initialized = false;
  bool _listening = false;
  bool _active = false;

  void Function(String transcript)? onTranscript;

  bool get isListening => _listening;

  Future<void> start({required void Function(String) onResult}) async {
    _active = true;
    onTranscript = onResult;
    try {
      _initialized = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _listening = false;
            if (_active) {
              _restartTimer?.cancel();
              _restartTimer = Timer(const Duration(milliseconds: 300), () {
                if (_active) _listen();
              });
            }
          } else if (status == 'listening') {
            _listening = true;
          }
        },
        onError: (_) {
          _listening = false;
          if (_active) {
            _restartTimer?.cancel();
            _restartTimer = Timer(const Duration(milliseconds: 1000), () {
              if (_active) _listen();
            });
          }
        },
      );

      if (_initialized) {
        await _listen();
      }
    } catch (_) {
      _initialized = false;
    }
  }

  Future<void> _listen() async {
    if (!_active || !_initialized || _listening) return;
    try {
      await _speechToText.listen(
        onResult: (result) {
          final words = result.recognizedWords.trim();
          if (words.isNotEmpty) {
            onTranscript?.call(words);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_IN',
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
        ),
      );
      _listening = true;
    } catch (_) {
      _listening = false;
    }
  }

  Future<void> stop() async {
    _active = false;
    _listening = false;
    _restartTimer?.cancel();
    _restartTimer = null;
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
    } catch (_) {}
  }
}
