part of 'creating_bloc.dart';

sealed class CreatingEvent extends Equatable {
  const CreatingEvent();

  @override
  List<Object> get props => [];
}

class StartCreatingEvent extends CreatingEvent {
  final String tripDescription;

  const StartCreatingEvent({required this.tripDescription});

  @override
  List<Object> get props => [tripDescription];
}

class FollowUpEvent extends CreatingEvent {
  const FollowUpEvent();
}

class SaveOfflineEvent extends CreatingEvent {
  const SaveOfflineEvent();
}

class ResetCreatingStateEvent extends CreatingEvent {
  const ResetCreatingStateEvent();
}
