import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechTestWidget extends StatefulWidget {
  const SpeechTestWidget({super.key});

  @override
  State<SpeechTestWidget> createState() => _SpeechTestWidgetState();
}

class _SpeechTestWidgetState extends State<SpeechTestWidget> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  String _status = 'Not started';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    print('🎤 Test Widget: Initializing speech...');

    // Check permission
    final permission = await Permission.microphone.request();
    print('🎤 Test Widget: Permission status: $permission');

    if (!permission.isGranted) {
      setState(() {
        _status = 'Permission denied';
      });
      return;
    }

    // Initialize speech recognition
    final available = await _speechToText.initialize();
    print('🎤 Test Widget: Speech available: $available');

    setState(() {
      _status = available ? 'Ready' : 'Not available';
    });
  }

  Future<void> _startListening() async {
    if (!_speechToText.isAvailable) {
      setState(() {
        _status = 'Speech recognition not available';
      });
      return;
    }

    setState(() {
      _isListening = true;
      _status = 'Listening...';
    });

    await _speechToText.listen(
      onResult: (result) {
        print('🎤 Test Widget: Result: "${result.recognizedWords}"');
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      partialResults: true,
    );
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
      _status = 'Stopped';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Speech Recognition Test'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Status: $_status'),
          const SizedBox(height: 16),
          Text('Recognized: $_recognizedText'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _isListening ? null : _startListening,
                child: const Text('Start'),
              ),
              ElevatedButton(
                onPressed: _isListening ? _stopListening : null,
                child: const Text('Stop'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
