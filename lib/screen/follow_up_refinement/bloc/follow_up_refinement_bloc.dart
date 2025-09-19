import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:itinera_ai/services/offline_service_storage.dart';

part 'follow_up_refinement_event.dart';
part 'follow_up_refinement_state.dart';

class FollowUpRefinementBloc
    extends Bloc<FollowUpRefinementEvent, FollowUpRefinementState> {
  final String originalPrompt;
  final Map<String, dynamic> currentItinerary;
  List<Map<String, dynamic>> conversationHistory = [];

  FollowUpRefinementBloc({
    required this.originalPrompt,
    required this.currentItinerary,
  }) : super(FollowUpRefinementInitial()) {
    on<FollowUpRefinementInitialEvent>(_onInitial);
    on<LoadInitialDataEvent>(_onLoadInitialData);
    on<SendFollowUpEvent>(_onSendFollowUp);
    on<RegenerateItineraryEvent>(_onRegenerateItinerary);
    on<SaveOfflineEvent>(_onSaveOffline);
    on<CopyItineraryEvent>(_onCopyItinerary);
    on<ShareItineraryEvent>(_onShareItinerary);
  }

  Future<void> _onInitial(
    FollowUpRefinementInitialEvent event,
    Emitter<FollowUpRefinementState> emit,
  ) async {
    conversationHistory = [
      {
        'role': 'user',
        'content': event.originalPrompt,
        'timestamp': DateTime.now().toIso8601String(),
      },
      {
        'role': 'assistant',
        'content': 'Here\'s your personalized itinerary based on your request:',
        'itinerary': event.currentItinerary,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ];

    emit(FollowUpRefinementLoaded(
      conversationHistory: conversationHistory,
      currentItinerary: event.currentItinerary,
      originalPrompt: event.originalPrompt,
    ));
  }

  Future<void> _onLoadInitialData(
    LoadInitialDataEvent event,
    Emitter<FollowUpRefinementState> emit,
  ) async {
    conversationHistory = [
      {
        'role': 'user',
        'content': event.originalPrompt,
        'timestamp': DateTime.now().toIso8601String(),
      },
      {
        'role': 'assistant',
        'content': 'Here\'s your personalized itinerary based on your request:',
        'itinerary': event.currentItinerary,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ];

    emit(FollowUpRefinementLoaded(
      conversationHistory: conversationHistory,
      currentItinerary: event.currentItinerary,
      originalPrompt: event.originalPrompt,
    ));
  }

  Future<void> _onSendFollowUp(
    SendFollowUpEvent event,
    Emitter<FollowUpRefinementState> emit,
  ) async {
    // Add user message to conversation
    conversationHistory.add({
      'role': 'user',
      'content': event.message,
      'timestamp': DateTime.now().toIso8601String(),
    });

    emit(FollowUpRefinementLoading());

    // Simulate error for testing - remove this in production
    if (event.message.toLowerCase().contains('skuba') ||
        event.message.toLowerCase().contains('scuba')) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate loading
      emit(FollowUpRefinementError(message: 'LLM failed to generate answer'));
      return;
    }

    try {
      // Generate AI response
      final aiResponse = await _generateFollowUpResponse(
        originalPrompt,
        currentItinerary,
        event.message,
        conversationHistory,
      );

      // Add AI response to conversation
      conversationHistory.add({
        'role': 'assistant',
        'content': aiResponse['message'],
        'itinerary': aiResponse['itinerary'],
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Auto-save the new itinerary if it's different
      if (aiResponse['itinerary'] != null) {
        await OfflineStorageService.saveItineraryOffline(
            aiResponse['itinerary']);
      }

      emit(FollowUpRefinementLoaded(
        conversationHistory: conversationHistory,
        currentItinerary: aiResponse['itinerary'] ?? currentItinerary,
        originalPrompt: originalPrompt,
      ));
    } catch (e) {
      emit(FollowUpRefinementError(message: e.toString()));
    }
  }

  Future<void> _onRegenerateItinerary(
    RegenerateItineraryEvent event,
    Emitter<FollowUpRefinementState> emit,
  ) async {
    emit(FollowUpRefinementLoading());

    try {
      // Get the last user message
      final lastUserMessage =
          conversationHistory.where((msg) => msg['role'] == 'user').lastOrNull;

      if (lastUserMessage != null) {
        // Regenerate response for the last user message
        final aiResponse = await _generateFollowUpResponse(
          originalPrompt,
          currentItinerary,
          lastUserMessage['content'],
          conversationHistory,
        );

        // Update the last AI response
        final lastAiIndex = conversationHistory.lastIndexWhere(
          (msg) => msg['role'] == 'assistant',
        );

        if (lastAiIndex != -1) {
          conversationHistory[lastAiIndex] = {
            'role': 'assistant',
            'content': aiResponse['message'],
            'itinerary': aiResponse['itinerary'],
            'timestamp': DateTime.now().toIso8601String(),
          };
        }

        // Auto-save the new itinerary
        if (aiResponse['itinerary'] != null) {
          await OfflineStorageService.saveItineraryOffline(
              aiResponse['itinerary']);
        }

        emit(FollowUpRefinementLoaded(
          conversationHistory: conversationHistory,
          currentItinerary: aiResponse['itinerary'] ?? currentItinerary,
          originalPrompt: originalPrompt,
        ));
      } else {
        emit(FollowUpRefinementError(message: 'No user message to regenerate'));
      }
    } catch (e) {
      emit(FollowUpRefinementError(message: e.toString()));
    }
  }

  Future<void> _onSaveOffline(
    SaveOfflineEvent event,
    Emitter<FollowUpRefinementState> emit,
  ) async {
    try {
      await OfflineStorageService.saveItineraryOffline(currentItinerary);
      emit(FollowUpRefinementSuccess(
          message: 'Itinerary saved offline successfully!'));
    } catch (e) {
      emit(FollowUpRefinementError(
          message: 'Failed to save offline: ${e.toString()}'));
    }
  }

  Future<void> _onCopyItinerary(
    CopyItineraryEvent event,
    Emitter<FollowUpRefinementState> emit,
  ) async {
    // This will be handled by the UI
    emit(FollowUpRefinementSuccess(message: 'Copied to clipboard'));
  }

  Future<void> _onShareItinerary(
    ShareItineraryEvent event,
    Emitter<FollowUpRefinementState> emit,
  ) async {
    // This will be handled by the UI
    emit(FollowUpRefinementSuccess(message: 'Sharing itinerary...'));
  }

  Future<Map<String, dynamic>> _generateFollowUpResponse(
    String originalPrompt,
    Map<String, dynamic> currentItinerary,
    String followUpMessage,
    List<Map<String, dynamic>> conversationHistory,
  ) async {
    try {
      // Use a more reliable API key or get it from environment
      final apiKey = 'AIzaSyCMXeRYwtx-PoRSTdpitdeeps-q7bet3WY';

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      print('🤖 Generating follow-up response for: $followUpMessage');

      final prompt = '''
You are a travel planning AI. The user is making a NEW travel request, not asking for modifications to the previous itinerary.

IGNORE the previous itinerary completely. Focus ONLY on the user's new request.

User's NEW travel request: "$followUpMessage"

Create a completely new itinerary based on this request. If the user asks for a multi-day trip (like "5 days from MH to GJ"), create a detailed itinerary with multiple days for that specific route.

IMPORTANT: Use the exact cities/states mentioned in the user's request. If they say "MH to GJ", create an itinerary from Maharashtra to Gujarat.

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
- Use proper city names and coordinates
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

        return {
          'message': 'Here\'s your updated itinerary based on your request:',
          'itinerary': jsonResponse,
        };
      } catch (e) {
        print('❌ JSON parsing failed: $e');
        print('Raw response: $responseText');

        // If JSON parsing fails, create a fallback response
        return {
          'message':
              'I\'ve updated your itinerary based on your request. Here are the details:',
          'itinerary': _createFallbackItinerary(followUpMessage),
        };
      }
    } catch (e) {
      print('❌ Gemini AI Error: $e');
      print('Error type: ${e.runtimeType}');

      return {
        'message':
            'I apologize, but I encountered an error while generating your itinerary. Please try again.',
        'itinerary': _createFallbackItinerary(followUpMessage),
      };
    }
  }

  Map<String, dynamic> _createFallbackItinerary(String request) {
    return {
      'id': 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      'title':
          'Day 1: ${request.substring(0, request.length > 30 ? 30 : request.length)}...',
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
