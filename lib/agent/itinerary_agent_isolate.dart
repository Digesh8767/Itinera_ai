import 'dart:async';
import 'dart:isolate';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:itinera_ai/utils/itinerary_schema.dart';

/// Message passed to the isolate
class ItineraryAgentRequest {
  final String apiKey;
  final String model;
  final String userPrompt;
  final Map<String, dynamic>? previousItinerary;
  final List<Map<String, dynamic>> conversationHistory;

  ItineraryAgentRequest({
    required this.apiKey,
    required this.model,
    required this.userPrompt,
    required this.conversationHistory,
    this.previousItinerary,
  });

  Map<String, dynamic> toJson() => {
        'apiKey': apiKey,
        'model': model,
        'userPrompt': userPrompt,
        'previousItinerary': previousItinerary,
        'conversationHistory': conversationHistory,
      };
}

/// Events emitted back to UI via SendPort
Map<String, dynamic> _eventToken(String token) => {
      'type': 'token',
      'token': token,
    };

Map<String, dynamic> _eventDone({Map<String, dynamic>? itinerary}) => {
      'type': 'done',
      if (itinerary != null) 'itinerary': itinerary,
    };

Map<String, dynamic> _eventError(String message) => {
      'type': 'error',
      'error': message,
    };

/// Entry point for the isolate
Future<void> itineraryAgentEntryPoint(SendPort sendPort) async {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  await for (final dynamic message in port) {
    if (message is Map && message['type'] == 'start') {
      final Map<String, dynamic> payload =
          message['payload'] as Map<String, dynamic>;
      try {
        final SendPort targetPort = message['clientPort'] is SendPort
            ? message['clientPort'] as SendPort
            : sendPort;

        final request = ItineraryAgentRequest(
          apiKey: payload['apiKey'] as String,
          model: payload['model'] as String,
          userPrompt: payload['userPrompt'] as String,
          conversationHistory: List<Map<String, dynamic>>.from(
              payload['conversationHistory'] as List),
          previousItinerary:
              payload['previousItinerary'] as Map<String, dynamic>?,
        );

        await _runAgent(targetPort, request);
      } catch (e) {
        print("Error $e");
        sendPort.send(_eventError(e.toString()));
      }
    }
  }
}

Future<void> _runAgent(SendPort sendPort, ItineraryAgentRequest request) async {
  // Phase 1: stream human-friendly text
  final textModel = GenerativeModel(
    model: request.model,
    apiKey: request.apiKey,
    generationConfig: GenerationConfig(
      temperature: 0.9,
      responseMimeType: 'text/plain',
    ),
  );

  final historyText = request.conversationHistory
      .map((m) => "${m['role']}: ${m['content']}")
      .join("\n");

  final previousJson = request.previousItinerary == null
      ? 'null'
      : jsonEncode(request.previousItinerary);

  final displayPrompt = '''
You're an expert travel assistant. Briefly describe Day 1 for the user's request in bullet-like, readable text (no JSON). Keep it concise and friendly.
User request: ${request.userPrompt}
Previous itinerary JSON (may be null): $previousJson
Conversation so far:\n$historyText
''';

  try {
    final displayStream =
        textModel.generateContentStream([Content.text(displayPrompt)]);
    await for (final ev in displayStream) {
      final t = ev.text;
      if (t == null || t.isEmpty) continue;
      sendPort.send(_eventToken(t));
    }

    // Phase 2: request strict JSON
    final jsonModel = GenerativeModel(
      model: request.model,
      apiKey: request.apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: itineraryDayOneSchema,
        temperature: 0.7,
      ),
    );

    final jsonPrompt = '''
Return Day 1 itinerary JSON only, strictly conforming to the schema. Title must start with "Day 1:".
User request: ${request.userPrompt}
''';
    final jsonResp =
        await jsonModel.generateContent([Content.text(jsonPrompt)]);
    final raw = (jsonResp.text ?? '').trim();
    final map = _extractJson(raw);
    final validated = validateItinerary(map);
    sendPort.send(_eventDone(itinerary: validated));
  } on GenerativeAIException catch (e) {
    print("Error $e");
    sendPort.send(_eventError('AI error: ${e.message}'));
  } catch (e) {
    sendPort.send(_eventError(e.toString()));
  }
}

Map<String, dynamic> _extractJson(String raw) {
  // Best-effort extraction of first JSON object
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start == -1 || end == -1 || end <= start) {
    throw FormatException('No JSON object found in LLM output');
  }
  final cleaned = raw.substring(start, end + 1);
  return jsonDecode(cleaned) as Map<String, dynamic>;
}
