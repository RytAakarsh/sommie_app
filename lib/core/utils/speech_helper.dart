// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_google_stt/flutter_google_stt.dart';

// class SpeechHelper {
//   static final SpeechHelper _instance = SpeechHelper._internal();
//   factory SpeechHelper() => _instance;
//   SpeechHelper._internal();

//   final FlutterGoogleStt _stt = FlutterGoogleStt();
//   bool _isListening = false;
//   String _lastWords = '';
//   StreamSubscription? _subscription;

//   bool get isListening => _isListening;

//   // Initialize with Google Cloud credentials
//   Future<void> initialize({
//     required String accessToken,
//     String languageCode = 'en-US',
//   }) async {
//     try {
//       await FlutterGoogleStt.initialize(
//         accessToken: accessToken,
//         languageCode: languageCode,
//       );
//       print('✅ Speech recognition initialized');
//     } catch (e) {
//       print('❌ Error initializing speech recognition: $e');
//     }
//   }

//   Future<void> startListening({
//     required Function(String) onResult,
//     required Function() onListening,
//     String? localeId,
//   }) async {
//     try {
//       _isListening = true;
//       onListening();

//       _subscription = _stt.onResult!.listen((result) {
//         _lastWords = result.transcript;
//         onResult(result.transcript);
//       });

//       await _stt.start();
//     } catch (e) {
//       print('❌ Error starting speech recognition: $e');
//       _isListening = false;
//     }
//   }

//   Future<void> stopListening() async {
//     await _subscription?.cancel();
//     await _stt.stop();
//     _isListening = false;
//   }

//   void dispose() {
//     _subscription?.cancel();
//     _stt.dispose();
//   }
// }


import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechHelper {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  bool get isAvailable => _speech.isAvailable;

  Future<bool> initialize() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    return available;
  }

  void startListening({
    required Function(String) onResult,
    required VoidCallback onListeningStart,
    required VoidCallback onListeningStop,
    String? localeId,
  }) async {
    if (!_speech.isAvailable) {
      await initialize();
    }
    
    _isListening = true;
    onListeningStart();
    
    await _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        onResult(_lastWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: localeId ?? 'en_US',
      onSoundLevelChange: (level) {},
    );
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  void dispose() {
    _speech.stop();
  }
}