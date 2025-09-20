import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextService {
  static final SpeechToTextService _instance = SpeechToTextService._internal();
  factory SpeechToTextService() => _instance;
  SpeechToTextService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  /// Request microphone permission
  Future<bool> _requestMicrophonePermission() async {
    debugPrint('🎤 Requesting microphone permission...');
    final status = await Permission.microphone.request();
    debugPrint('🎤 Microphone permission status: $status');
    debugPrint('🎤 Permission granted: ${status.isGranted}');
    return status.isGranted;
  }

  /// Initialize speech-to-text service
  Future<bool> initialize() async {
    if (_isInitialized) {
      debugPrint('🎤 Speech service already initialized');
      return true;
    }

    try {
      debugPrint('🎤 Starting speech service initialization...');

      // Request microphone permission first
      final hasPermission = await _requestMicrophonePermission();
      if (!hasPermission) {
        debugPrint('🎤 Microphone permission denied');
        return false;
      }
      debugPrint('🎤 Microphone permission granted');

      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          debugPrint('🎤 Speech recognition error: $error');
          _isListening = false;
        },
        onStatus: (status) {
          debugPrint('🎤 Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
      );

      debugPrint('🎤 Speech recognition initialized: $_isInitialized');
      debugPrint(
          '🎤 Speech recognition available: ${_speechToText.isAvailable}');
      debugPrint(
          '🎤 Speech recognition has permission: ${_speechToText.hasPermission}');

      // Check if speech recognition is actually available
      if (_isInitialized && !_speechToText.isAvailable) {
        debugPrint('🎤 Speech recognition initialized but not available');
        _isInitialized = false;
      }
    } catch (e) {
      debugPrint('🎤 Failed to initialize speech recognition: $e');
      _isInitialized = false;
    }

    debugPrint('🎤 Final initialization result: $_isInitialized');
    return _isInitialized;
  }

  /// Check if speech recognition is available
  bool get isAvailable => _isInitialized && _speechToText.isAvailable;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Start listening for speech input
  Future<void> startListening({
    required Function(String) onResult,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
    bool partialResults = true,
    String localeId = 'en_US',
  }) async {
    debugPrint('Starting speech recognition...');

    if (!_isInitialized) {
      debugPrint('Speech recognition not initialized, initializing...');
      final initialized = await initialize();
      if (!initialized) {
        debugPrint('Failed to initialize speech recognition');
        throw Exception('Speech recognition not available on this device');
      }
    }

    if (!_speechToText.isAvailable) {
      debugPrint('Speech recognition is not available');
      throw Exception('Speech recognition not available on this device');
    }

    if (_isListening) {
      debugPrint('Already listening, stopping previous session...');
      await stopListening();
    }

    debugPrint('Starting to listen...');
    _isListening = true;

    try {
      await _speechToText.listen(
        onResult: (result) {
          debugPrint('🎤 Speech result: "${result.recognizedWords}"');
          debugPrint('🎤 Speech confidence: ${result.confidence}');
          debugPrint('🎤 Speech final: ${result.finalResult}');
          onResult(result.recognizedWords);
        },
        listenFor: listenFor,
        pauseFor: pauseFor,
        partialResults: partialResults,
        localeId: localeId,
      );
      debugPrint('Speech recognition started successfully');
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      _isListening = false;
      throw Exception('Failed to start speech recognition: $e');
    }
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  /// Cancel speech recognition
  Future<void> cancel() async {
    await _speechToText.cancel();
    _isListening = false;
  }

  /// Toggle listening state
  Future<void> toggleListening({
    required Function(String) onResult,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
    bool partialResults = true,
    String localeId = 'en_US',
  }) async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening(
        onResult: onResult,
        listenFor: listenFor,
        pauseFor: pauseFor,
        partialResults: partialResults,
        localeId: localeId,
      );
    }
  }

  /// Show error message for speech recognition issues
  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFFFF6B35),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }
}
