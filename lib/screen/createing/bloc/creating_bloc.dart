import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:itinera_ai/services/firestore_service.dart';

part 'creating_event.dart';
part 'creating_state.dart';

class CreatingBloc extends Bloc<CreatingEvent, CreatingState> {
  CreatingBloc() : super(CreatingInitial()) {
    on<StartCreatingEvent>(_onStartCreating);
    on<FollowUpEvent>(_onFollowUp);
    on<SaveOfflineEvent>(_onSaveOffline);
    on<ResetCreatingStateEvent>(_onResetCreatingState);
  }

  Future<void> _onStartCreating(
    StartCreatingEvent event,
    Emitter<CreatingState> emit,
  ) async {
    emit(const CreatingInProgress(
        message: 'Curating a perfect plan for you...'));

    try {
      // Simulate AI processing time
      await Future.delayed(const Duration(seconds: 3));

      // Mock AI response - replace with actual AI integration
      final itinerary = _generateMockItinerary(event.tripDescription);

      // Save to Firestore
      final tripData = {
        'title': _extractTitle(event.tripDescription),
        'description': event.tripDescription,
        'itinerary': itinerary,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await FirestoreService.createTrip(tripData: tripData);

      emit(CreatingCompleted(itinerary: itinerary));
    } catch (e) {
      emit(CreatingFailed(
          message: 'Failed to create itinerary: ${e.toString()}'));
    }
  }

  Future<void> _onFollowUp(
    FollowUpEvent event,
    Emitter<CreatingState> emit,
  ) async {
    // Navigate to follow-up screen or show dialog
    emit(const FollowUpSuccess(message: 'Follow-up initiated'));
  }

  Future<void> _onSaveOffline(
    SaveOfflineEvent event,
    Emitter<CreatingState> emit,
  ) async {
    // Save current itinerary offline
    emit(const SaveOfflineSuccess(message: 'Itinerary saved offline'));
  }

  void _onResetCreatingState(
    ResetCreatingStateEvent event,
    Emitter<CreatingState> emit,
  ) {
    emit(CreatingInitial());
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
