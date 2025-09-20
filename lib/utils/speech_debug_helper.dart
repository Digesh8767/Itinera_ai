import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechDebugHelper {
  static Future<void> debugSpeechRecognition(BuildContext context) async {
    final speechToText = SpeechToText();

    // Check permissions
    final micPermission = await Permission.microphone.status;
    debugPrint('🔍 Microphone Permission Status: $micPermission');

    // Check if speech recognition is available
    final isAvailable = await speechToText.initialize();
    debugPrint('🔍 Speech Recognition Available: $isAvailable');

    if (isAvailable) {
      debugPrint(
          '🔍 Speech Recognition isAvailable: ${speechToText.isAvailable}');
      debugPrint(
          '🔍 Speech Recognition hasPermission: ${speechToText.hasPermission}');
      debugPrint(
          '🔍 Speech Recognition locales: ${await speechToText.locales()}');
    }

    // Show debug info to user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Speech Recognition Debug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Microphone Permission: $micPermission'),
            Text('Speech Available: $isAvailable'),
            if (isAvailable) ...[
              Text('isAvailable: ${speechToText.isAvailable}'),
              Text('hasPermission: ${speechToText.hasPermission}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (micPermission.isDenied)
            TextButton(
              onPressed: () async {
                await Permission.microphone.request();
                Navigator.pop(context);
                debugSpeechRecognition(context);
              },
              child: const Text('Request Permission'),
            ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await testSpeechRecognition(context);
            },
            child: const Text('Test Speech'),
          ),
        ],
      ),
    );
  }

  static Future<void> testSpeechRecognition(BuildContext context) async {
    final speechToText = SpeechToText();
    await speechToText.initialize();

    String recognizedText = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Testing Speech Recognition'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Speak now...'),
            const SizedBox(height: 16),
            Text('Recognized: $recognizedText'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await speechToText.stop();
              Navigator.pop(context);
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );

    await speechToText.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;
        // Update the dialog content
        Navigator.of(context).pop();
        testSpeechRecognition(context);
      },
      listenFor: const Duration(seconds: 10),
      partialResults: true,
    );
  }
}
