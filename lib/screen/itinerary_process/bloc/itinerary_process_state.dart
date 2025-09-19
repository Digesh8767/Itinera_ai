part of 'itinerary_process_bloc.dart';

sealed class ItineraryProcessState extends Equatable {
  const ItineraryProcessState();

  @override
  List<Object> get props => [];
}

final class ItineraryProcessInitial extends ItineraryProcessState {}

class ItineraryCreating extends ItineraryProcessState {
  final String tripDescription;
  final int progress;

  const ItineraryCreating({
    required this.tripDescription,
    this.progress = 0,
  });

  @override
  List<Object> get props => [tripDescription, progress];
}

class ItineraryCreated extends ItineraryProcessState {
  final Map<String, dynamic> itinerary;

  const ItineraryCreated({required this.itinerary});

  @override
  List<Object> get props => [itinerary];
}

class ItineraryProcessError extends ItineraryProcessState {
  final String message;

  const ItineraryProcessError({required this.message});

  @override
  List<Object> get props => [message];
}

class FollowUpLoading extends ItineraryProcessState {}

class FollowUpSuccess extends ItineraryProcessState {
  final String message;

  const FollowUpSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class SaveOfflineLoading extends ItineraryProcessState {}

class SaveOfflineSuccess extends ItineraryProcessState {
  final String message;

  const SaveOfflineSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class SaveOfflineDuringCreationLoading extends ItineraryProcessState {}

class SaveOfflineDuringCreationSuccess extends ItineraryProcessState {
  final String message;
  const SaveOfflineDuringCreationSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class FollowUpDuringCreationMessage extends ItineraryProcessState {
  final String message;
  const FollowUpDuringCreationMessage({required this.message});
  @override
  List<Object> get props => [message];
}
