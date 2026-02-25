import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechHelper {
  static final SpeechHelper _instance = SpeechHelper._internal();
  factory SpeechHelper() => _instance;
  SpeechHelper._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  bool get isListening => _isListening;

  Future<bool> initialize() async {
    return await _speech.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function() onListening,
    String? localeId,
  }) async {
    if (!_speech.isAvailable) {
      if (!await initialize()) return;
    }

    _isListening = true;
    onListening();

    await _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        onResult(result.recognizedWords);
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    _isListening = false;
  }

  void dispose() {
    _speech.stop();
  }
}
