part of 'creating_bloc.dart';

sealed class CreatingState extends Equatable {
  const CreatingState();

  @override
  List<Object> get props => [];
}

final class CreatingInitial extends CreatingState {}

class CreatingInProgress extends CreatingState {
  final String message;

  const CreatingInProgress({required this.message});

  @override
  List<Object> get props => [message];
}

class CreatingCompleted extends CreatingState {
  final String itinerary;

  const CreatingCompleted({required this.itinerary});

  @override
  List<Object> get props => [itinerary];
}

class CreatingFailed extends CreatingState {
  final String message;

  const CreatingFailed({required this.message});

  @override
  List<Object> get props => [message];
}

class FollowUpSuccess extends CreatingState {
  final String message;

  const FollowUpSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class SaveOfflineSuccess extends CreatingState {
  final String message;

  const SaveOfflineSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
