part of 'creating_itinerary_bloc.dart';

sealed class CreatingItineraryEvent extends Equatable {
  const CreatingItineraryEvent();

  @override
  List<Object> get props => [];
}

class StartCreatingItineraryEvent extends CreatingItineraryEvent {
  final String tripDescription;

  const StartCreatingItineraryEvent({required this.tripDescription});

  @override
  List<Object> get props => [tripDescription];
}

class SaveOfflineEvent extends CreatingItineraryEvent {
  const SaveOfflineEvent();
}
