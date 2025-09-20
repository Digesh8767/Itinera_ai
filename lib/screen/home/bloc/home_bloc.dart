import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:itinera_ai/services/firestore_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<CreateItineraryEvent>(_onCreateItinerary);
    on<LoadSavedItinerariesEvent>(_onLoadSavedItineraries);
    on<DeleteItineraryEvent>(_onDeleteItinerary);
    on<ResetHomeStateEvent>(_onResetHomeState);
  }

  Future<void> _onCreateItinerary(
    CreateItineraryEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(ItineraryCreating());

    try {
      // Simulate AI processing (replace with actual AI API call)
      await Future.delayed(const Duration(seconds: 3));

      // Mock AI response - replace with actual AI integration
      final aiResponse = _generateMockItinerary(event.tripDescription);

      // Save to Firestore
      final tripData = {
        'title': _extractTitle(event.tripDescription),
        'description': event.tripDescription,
        'itinerary': aiResponse,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await FirestoreService.createTrip(tripData: tripData);

      emit(ItineraryCreated(
        itinerary: aiResponse,
        message: 'Itinerary created successfully!',
      ));
    } catch (e) {
      emit(ItineraryCreationFailed(
        message: 'Failed to create itinerary: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadSavedItineraries(
    LoadSavedItinerariesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      // Load from Firestore
      final querySnapshot = await FirestoreService.getUserTrips().first;
      final itineraries = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'createdAt': data['createdAt'] ?? '',
        };
      }).toList();

      emit(SavedItinerariesLoaded(itineraries: itineraries));
    } catch (e) {
      // Fallback to mock data if Firestore fails
      final mockItineraries = [
        {
          'id': '1',
          'title': 'Japan Trip, 20 days vacation, explore ky...',
          'description': 'Japan Trip, 20 days vacation, explore ky...',
          'createdAt': 'March 2024',
        },
        {
          'id': '2',
          'title': 'India Trip, 7 days work trip, suggest affor...',
          'description': 'India Trip, 7 days work trip, suggest affor...',
          'createdAt': 'February 2024',
        },
        {
          'id': '3',
          'title': 'Europe trip, include Paris, Berlin, Dortmun...',
          'description': 'Europe trip, include Paris, Berlin, Dortmun...',
          'createdAt': 'January 2024',
        },
        {
          'id': '4',
          'title': 'Two days weekend getaway to somewhe...',
          'description': 'Two days weekend getaway to somewhe...',
          'createdAt': 'December 2023',
        },
      ];
      emit(SavedItinerariesLoaded(itineraries: mockItineraries));
    }
  }

  Future<void> _onDeleteItinerary(
    DeleteItineraryEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await FirestoreService.deleteTrip(event.itineraryId);
      emit(const ItineraryDeleted(message: 'Itinerary deleted successfully!'));
    } catch (e) {
      emit(ItineraryCreationFailed(
        message: 'Failed to delete itinerary: ${e.toString()}',
      ));
    }
  }

  void _onResetHomeState(
    ResetHomeStateEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeInitial());
  }

  // Mock AI function - replace with actual AI API integration
  String _generateMockItinerary(String description) {
    return '''
Day 1: Arrival and Relaxation
- Check into your accommodation
- Explore local area
- Enjoy a welcome dinner

Day 2-3: Main Activities
- Visit key attractions
- Experience local culture
- Try local cuisine

Day 4-5: Adventure Time
- Outdoor activities
- Nature exploration
- Photography opportunities

Day 6-7: Final Days
- Last-minute shopping
- Relaxation time
- Departure preparation
''';
  }

  String _extractTitle(String description) {
    if (description.length > 50) {
      return '${description.substring(0, 47)}...';
    }
    return description;
  }
}
