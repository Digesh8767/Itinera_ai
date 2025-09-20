import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:itinera_ai/services/offline_service_storage.dart';
import 'dart:isolate';
import 'dart:async';
import 'package:itinera_ai/agent/itinerary_agent_isolate.dart';
import 'package:itinera_ai/services/local_itinerary_templates.dart';

part 'creating_itinerary_event.dart';
part 'creating_itinerary_state.dart';

enum CreatingStage {
  analyzing,
  researching,
  planning,
  optimizing,
  finalizing,
}

class CreatingItineraryBloc
    extends Bloc<CreatingItineraryEvent, CreatingItineraryState> {
  CreatingItineraryBloc() : super(CreatingItineraryInitial()) {
    on<StartCreatingItineraryEvent>(_onStartCreatingItinerary);
    on<SaveOfflineEvent>(_onSaveOffline);
  }

  Future<void> _onStartCreatingItinerary(
    StartCreatingItineraryEvent event,
    Emitter<CreatingItineraryState> emit,
  ) async {
    try {
      // 0) If prompt matches a local template, skip AI + stream, emit immediately
      final local =
          LocalItineraryTemplates.findForPrompt(event.tripDescription);
      if (local != null) {
        emit(CreatingItineraryCompleted(itinerary: local));
        return;
      }
      // Start with analyzing stage
      emit(CreatingItineraryProgress(
          stage: CreatingStage.analyzing, progress: 0.0));
      await _simulateDelay(800);

      // Researching stage
      emit(CreatingItineraryProgress(
          stage: CreatingStage.researching, progress: 0.2));
      await _simulateDelay(1000);

      // Planning stage
      emit(CreatingItineraryProgress(
          stage: CreatingStage.planning, progress: 0.4));
      await _simulateDelay(1200);

      // Optimizing stage
      emit(CreatingItineraryProgress(
          stage: CreatingStage.optimizing, progress: 0.6));
      await _simulateDelay(1000);

      // Finalizing stage
      emit(CreatingItineraryProgress(
          stage: CreatingStage.finalizing, progress: 0.8));
      await _simulateDelay(800);

      // Stream from agent isolate instead of waiting
      final receivePort = ReceivePort();
      await Isolate.spawn(itineraryAgentEntryPoint, receivePort.sendPort);
      final agentPort = await receivePort.first as SendPort;

      // Create a dedicated client port so multiple widgets/devices don't share streams
      final clientPort = ReceivePort();
      final clientSend = clientPort.sendPort;

      // Start agent
      agentPort.send({
        'type': 'start',
        'payload': ItineraryAgentRequest(
          apiKey: 'AIzaSyCMXeRYwtx-PoRSTdpitdeeps-q7bet3WY',
          model: 'gemini-1.5-flash',
          userPrompt: event.tripDescription,
          conversationHistory: const [],
        ).toJson(),
        'clientPort': clientSend,
      });

      final buffer = StringBuffer();
      bool completed = false;
      await for (final dynamic msg in clientPort) {
        if (msg is Map<String, dynamic>) {
          final type = msg['type'] as String?;
          if (type == 'token') {
            final token = msg['token'] as String?;
            if (token != null && token.isNotEmpty) {
              buffer.write(token);
              emit(CreatingItineraryStreaming(
                  partialText: buffer.toString(), progress: 0.9));
            }
          } else if (type == 'done') {
            final itinerary = (msg['itinerary'] as Map<String, dynamic>?) ??
                await _generateItineraryWithGemini(event.tripDescription);
            emit(CreatingItineraryCompleted(itinerary: itinerary));
            completed = true;
            clientPort.close();
            receivePort.close();
            break;
          } else if (type == 'error') {
            emit(CreatingItineraryError(
                message: (msg['error'] as String?) ?? 'AI error'));
            completed = true;
            clientPort.close();
            receivePort.close();
            break;
          }
        }
      }
      if (!completed) {
        // Safety timeout fallback
        final itinerary =
            await _generateItineraryWithGemini(event.tripDescription);
        emit(CreatingItineraryCompleted(itinerary: itinerary));
      }
    } catch (e) {
      emit(CreatingItineraryError(message: e.toString()));
    }
  }

  Future<void> _onSaveOffline(
    SaveOfflineEvent event,
    Emitter<CreatingItineraryState> emit,
  ) async {
    try {
      if (state is CreatingItineraryCompleted) {
        final completedState = state as CreatingItineraryCompleted;
        await OfflineStorageService.saveItineraryOffline(
            completedState.itinerary);
        emit(CreatingItinerarySuccess(
            message: 'Itinerary saved offline successfully!'));
      } else {
        // If itinerary is not completed, don't emit error, just ignore
        // The UI should prevent this from happening anyway
        return;
      }
    } catch (e) {
      emit(CreatingItineraryError(
          message: 'Failed to save offline: ${e.toString()}'));
    }
  }

  Future<void> _simulateDelay(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  Future<Map<String, dynamic>> _generateItineraryWithGemini(
      String tripDescription) async {
    try {
      // Use a more reliable API key or get it from environment
      final apiKey = 'AIzaSyCMXeRYwtx-PoRSTdpitdeeps-q7bet3WY';

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      print('🤖 Generating itinerary for: $tripDescription');

      final prompt = '''
Create a travel itinerary based on this description: "$tripDescription"

Generate a simple, clean itinerary in this EXACT format:
{
  "id": "unique_id",
  "title": "Day 1: [Brief Day Title]",
  "destination": "Destination City, Country",
  "origin": "Origin City, Country",
  "duration": "Xhrs Xmins",
  "activities": [
    {
      "time": "Morning/Afternoon/Evening/Transfer/Accommodation",
      "description": "Activity description"
    }
  ]
}

Requirements:
- Generate realistic travel times and activities
- Include specific locations and landmarks
- Make it practical and achievable
- Use proper city names
- Keep descriptions concise but informative
- Focus on the user's specific request

Example format:
{
  "id": "bali_trip_001",
  "title": "Day 1: Arrival in Bali & Settle in Ubud",
  "destination": "Bali, Indonesia",
  "origin": "Mumbai, India",
  "duration": "11hrs 5mins",
  "activities": [
    {
      "time": "Morning",
      "description": "Arrive in Bali, Denpasar Airport"
    },
    {
      "time": "Transfer", 
      "description": "Private driver to Ubud (around 1.5 hours)"
    },
    {
      "time": "Accommodation",
      "description": "Check-in at a peaceful boutique hotel or villa in Ubud"
    },
    {
      "time": "Afternoon",
      "description": "Explore Ubud's local area, walk around the tranquil rice terraces at Tegallalang"
    },
    {
      "time": "Evening",
      "description": "Dinner at Locavore (known for farm-to-table dishes in peaceful environment)"
    }
  ]
}

Generate ONLY the JSON response, no additional text.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text ?? '';

      print('🤖 Gemini Response: $responseText');

      // Parse the JSON response
      try {
        // Clean the response text to extract JSON
        String cleanResponse = responseText.trim();

        // Try to find JSON in the response
        if (cleanResponse.contains('{') && cleanResponse.contains('}')) {
          final startIndex = cleanResponse.indexOf('{');
          final endIndex = cleanResponse.lastIndexOf('}') + 1;
          cleanResponse = cleanResponse.substring(startIndex, endIndex);
        }

        final jsonResponse = json.decode(cleanResponse);
        print('✅ Successfully parsed JSON: $jsonResponse');

        return jsonResponse;
      } catch (e) {
        print('❌ JSON parsing failed: $e');
        print('Raw response: $responseText');

        // If JSON parsing fails, create a fallback response
        return _createFallbackItinerary(tripDescription);
      }
    } catch (e) {
      print('❌ Gemini AI Error: $e');
      print('Error type: ${e.runtimeType}');

      return _createFallbackItinerary(tripDescription);
    }
  }

  Map<String, dynamic> _createFallbackItinerary(String tripDescription) {
    return {
      'id': 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      'title':
          'Day 1: ${tripDescription.substring(0, tripDescription.length > 30 ? 30 : tripDescription.length)}...',
      'destination': 'Destination',
      'origin': 'Origin',
      'duration': 'TBD',
      'activities': [
        {
          'time': 'Morning',
          'description': 'Start your journey based on your request',
        },
        {
          'time': 'Afternoon',
          'description': 'Explore and enjoy your trip',
        },
        {
          'time': 'Evening',
          'description': 'Relax and prepare for the next day',
        },
      ],
    };
  }
}
