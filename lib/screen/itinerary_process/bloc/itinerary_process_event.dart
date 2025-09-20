part of 'itinerary_process_bloc.dart';

sealed class ItineraryProcessEvent extends Equatable {
  const ItineraryProcessEvent();

  @override
  List<Object> get props => [];
}

class ResetItineraryProcessEvent extends ItineraryProcessEvent {
  const ResetItineraryProcessEvent();
}

class StartCreatingItineraryEvent extends ItineraryProcessEvent {
  final String tripDescription;

  const StartCreatingItineraryEvent({required this.tripDescription});

  @override
  List<Object> get props => [tripDescription];
}

class FollowUpEvent extends ItineraryProcessEvent {
  const FollowUpEvent();
}

class SaveOfflineEvent extends ItineraryProcessEvent {
  const SaveOfflineEvent();
}

class OpenInMapsEvent extends ItineraryProcessEvent {
  const OpenInMapsEvent();
}

class GoBackEvent extends ItineraryProcessEvent {
  const GoBackEvent();
}

class SaveOfflineDuringCreationEvent extends ItineraryProcessEvent {
  const SaveOfflineDuringCreationEvent();
}

class FollowUpDuringCreationEvent extends ItineraryProcessEvent {
  const FollowUpDuringCreationEvent();
}
