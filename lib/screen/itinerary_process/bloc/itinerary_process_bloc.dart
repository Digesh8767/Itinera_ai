import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:itinera_ai/services/offline_service_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

part 'itinerary_process_event.dart';
part 'itinerary_process_state.dart';

class ItineraryProcessBloc
    extends Bloc<ItineraryProcessEvent, ItineraryProcessState> {
  ItineraryProcessBloc() : super(ItineraryProcessInitial()) {
    on<ResetItineraryProcessEvent>(_onResetItineraryProcess);
    on<StartCreatingItineraryEvent>(_onStartCreatingItinerary);
    on<FollowUpEvent>(_onFollowUp);
    on<SaveOfflineEvent>(_onSaveOffline);
    on<SaveOfflineDuringCreationEvent>(_onSaveOfflineDuringCreation);
    on<FollowUpDuringCreationEvent>(_onFollowUpDuringCreation);

    on<OpenInMapsEvent>(_onOpenInMaps);
    on<GoBackEvent>(_onGoBack);
  }

  Future<void> _onResetItineraryProcess(
    ResetItineraryProcessEvent event,
    Emitter<ItineraryProcessState> emit,
  ) async {
    emit(ItineraryProcessInitial());
  }

  Future<void> _onSaveOfflineDuringCreation(
    SaveOfflineDuringCreationEvent event,
    Emitter<ItineraryProcessState> emit,
  ) async {
    emit(SaveOfflineDuringCreationLoading());

    try {
      // Show message that we're waiting for creation to complete
      emit(SaveOfflineDuringCreationSuccess(
          message:
              'Please wait until trip creation is complete, then we\'ll save it offline!'));
    } catch (e) {
      emit(ItineraryProcessError(message: e.toString()));
    }
  }

  Future<void> _onFollowUpDuringCreation(
    FollowUpDuringCreationEvent event,
    Emitter<ItineraryProcessState> emit,
  ) async {
    try {
      emit(FollowUpDuringCreationMessage(
          message:
              'Please wait until trip creation is complete, then you can refine it!'));
    } catch (e) {
      emit(ItineraryProcessError(message: e.toString()));
    }
  }

  Future<void> _onStartCreatingItinerary(
    StartCreatingItineraryEvent event,
    Emitter<ItineraryProcessState> emit,
  ) async {
    emit(
        ItineraryCreating(tripDescription: event.tripDescription, progress: 0));

    try {
      // Simulate progress updates
      for (int i = 1; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        emit(ItineraryCreating(
            tripDescription: event.tripDescription, progress: i));
      }

      // Generate itinerary using Gemini AI
      final itinerary =
          await _generateItineraryWithGemini(event.tripDescription);

      emit(ItineraryCreated(itinerary: itinerary));

      // Check if user requested to save offline during creation
      if (state is SaveOfflineDuringCreationLoading) {
        await _saveItineraryOffline(itinerary);
      }
    } catch (e) {
      emit(ItineraryProcessError(message: e.toString()));
    }
  }

  Future<Map<String, dynamic>> _generateItineraryWithGemini(
      String tripDescription) async {
    try {
      // Initialize Gemini AI
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyCMXeRYwtx-PoRSTdpitdeeps-q7bet3WY',
      );

      //   final prompt = '''
      //   Create a detailed travel itinerary based on this description: "$tripDescription"

      //   Please provide a structured response in JSON format with the following EXACT structure:
      //   {
      //     "title": "Trip Title",
      //     "startDate": "YYYY-MM-DD",
      //     "endDate": "YYYY-MM-DD",
      //     "days": [
      //       {
      //         "date": "YYYY-MM-DD",
      //         "summary": "Day summary",
      //         "items": [
      //           {
      //             "time": "HH:MM",
      //             "activity": "Activity description",
      //             "location": "latitude,longitude"
      //           }
      //         ]
      //       }
      //     ]
      //   }

      //   Requirements:
      //   - Use realistic dates (start from tomorrow if no specific date mentioned)
      //   - Include actual GPS coordinates for locations
      //   - Make activities specific and detailed
      //   - Include proper time formatting (24-hour format)
      //   - Generate 3-7 days of itinerary
      //   - Use real places with accurate coordinates

      //   Example format:
      //   {
      //     "title": "Kyoto 5-Day Solo Trip",
      //     "startDate": "2025-04-10",
      //     "endDate": "2025-04-15",
      //     "days": [
      //       {
      //         "date": "2025-04-10",
      //         "summary": "Fushimi Inari & Gion",
      //         "items": [
      //           { "time": "09:00", "activity": "Climb Fushimi Inari Shrine", "location": "34.9671,135.7727" },
      //           { "time": "14:00", "activity": "Lunch at Nishiki Market", "location": "35.0047,135.7630" },
      //           { "time": "18:30", "activity": "Evening walk in Gion", "location": "35.0037,135.7788" }
      //         ]
      //       }
      //     ]
      //   }
      // ''';

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
      - Keep it simple like the example below
      - Use realistic destinations and activities
      - Include proper travel duration
      - Make activities specific but concise
      - Focus on one day of detailed activities
      
      Example format:
      {
        "id": "1234567890",
        "title": "Day 1: Arrival in Bali & Settle in Ubud",
        "destination": "Bali, Indonesia", 
        "origin": "Mumbai, India",
        "duration": "11hrs 5mins",
        "activities": [
          {
            "time": "Morning",
            "description": "Arrive in Bali, Denpasar Airport."
          },
          {
            "time": "Transfer", 
            "description": "Private driver to Ubud (around 1.5 hours)."
          },
          {
            "time": "Accommodation",
            "description": "Check-in at a peaceful boutique hotel or villa in Ubud (e.g., Ubud Aura Retreat)."
          },
          {
            "time": "Afternoon",
            "description": "Explore Ubud's local area, walk around the tranquil rice terraces at Tegallalang."
          },
          {
            "time": "Evening",
            "description": "Dinner at Locavore (known for farm-to-table dishes in peaceful environment)."
          }
        ]
      }
    ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      // Parse the response
      final responseText = response.text ?? '';

      // Extract JSON from response (Gemini might include markdown formatting)
      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = responseText.substring(jsonStart, jsonEnd);
        final itinerary = json.decode(jsonString);

        // Validate and add ID if missing
        if (!itinerary.containsKey('id')) {
          itinerary['id'] = DateTime.now().millisecondsSinceEpoch.toString();
        }

        return itinerary;
      } else {
        // Fallback if JSON parsing fails
        return _createFallbackItinerary(tripDescription);
      }
    } catch (e) {
      print('Gemini AI Error: $e');
      // Return fallback itinerary if AI fails
      return _createFallbackItinerary(tripDescription);
    }
  }

  Map<String, dynamic> _createFallbackItinerary(String tripDescription) {
    final now = DateTime.now();
    final startDate = now.add(const Duration(days: 1));
    final endDate = startDate.add(const Duration(days: 4));

    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'AI Generated Trip',
      'startDate': _formatDate(startDate),
      'endDate': _formatDate(endDate),
      'days': [
        {
          'date': _formatDate(startDate),
          'summary': 'Arrival and Exploration',
          'items': [
            {
              'time': '09:00',
              'activity': 'Arrive at destination',
              'location': '0.0,0.0'
            },
            {
              'time': '14:00',
              'activity': 'Lunch at local restaurant',
              'location': '0.0,0.0'
            },
            {
              'time': '18:30',
              'activity': 'Evening exploration',
              'location': '0.0,0.0'
            }
          ]
        }
      ]
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _onFollowUp(
    FollowUpEvent event,
    Emitter<ItineraryProcessState> emit,
  ) async {
    emit(FollowUpLoading());

    try {
      // Simulate follow-up processing
      await Future.delayed(const Duration(seconds: 2));

      emit(FollowUpSuccess(message: 'Follow-up request sent successfully!'));
    } catch (e) {
      print("Error $e");
      emit(ItineraryProcessError(message: e.toString()));
    }
  }

  // Add helper method for saving offline
  Future<void> _saveItineraryOffline(Map<String, dynamic> itinerary) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/itinerary_${itinerary['id']}.json');
      await file.writeAsString(json.encode(itinerary));
      print('✅ Itinerary saved offline: ${itinerary['id']}');
    } catch (e) {
      print('❌ Error saving offline: $e');
    }
  }

  Future<void> _onSaveOffline(
    SaveOfflineEvent event,
    Emitter<ItineraryProcessState> emit,
  ) async {
    emit(SaveOfflineLoading());

    try {
      if (state is ItineraryCreated) {
        final currentState = state as ItineraryCreated;
        final itinerary = currentState.itinerary;

        // Save to local storage
        final success =
            await OfflineStorageService.saveItineraryOffline(itinerary);

        if (success) {
          emit(SaveOfflineSuccess(
              message: 'Itinerary saved offline successfully!'));
        } else {
          emit(ItineraryProcessError(
              message: 'Failed to save itinerary offline'));
        }
      }
    } catch (e) {
      print("Error $e");
      emit(ItineraryProcessError(message: e.toString()));
    }
  }

  Future<void> _onOpenInMaps(
    OpenInMapsEvent event,
    Emitter<ItineraryProcessState> emit,
  ) async {
    try {
      if (state is ItineraryCreated) {
        final currentState = state as ItineraryCreated;
        final itinerary = currentState.itinerary;
        final destination = itinerary['destination'] ?? 'Bali, Indonesia';
        final url =
            'https://maps.google.com/maps?q=${Uri.encodeComponent(destination)}';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        }
      }
    } catch (e) {
      print("Error $e");
      emit(ItineraryProcessError(
          message: 'Failed to open maps: ${e.toString()}'));
    }
  }

  Future<void> _onGoBack(
    GoBackEvent event,
    Emitter<ItineraryProcessState> emit,
  ) async {
    // Reset state when going back to ensure fresh start for next trip
    emit(ItineraryProcessInitial());
  }
}
