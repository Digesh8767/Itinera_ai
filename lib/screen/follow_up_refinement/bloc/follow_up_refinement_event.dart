part of 'follow_up_refinement_bloc.dart';

abstract class FollowUpRefinementEvent extends Equatable {
  const FollowUpRefinementEvent();

  @override
  List<Object> get props => [];
}

class FollowUpRefinementInitialEvent extends FollowUpRefinementEvent {
  final String originalPrompt;
  final Map<String, dynamic> currentItinerary;

  const FollowUpRefinementInitialEvent({
    required this.originalPrompt,
    required this.currentItinerary,
  });

  @override
  List<Object> get props => [originalPrompt, currentItinerary];
}

class LoadInitialDataEvent extends FollowUpRefinementEvent {
  final String originalPrompt;
  final Map<String, dynamic> currentItinerary;

  const LoadInitialDataEvent({
    required this.originalPrompt,
    required this.currentItinerary,
  });

  @override
  List<Object> get props => [originalPrompt, currentItinerary];
}

class SendFollowUpEvent extends FollowUpRefinementEvent {
  final String followUpMessage;
  final String message;

  const SendFollowUpEvent({
    required this.followUpMessage,
    String? message,
  }) : message = message ?? followUpMessage;

  @override
  List<Object> get props => [followUpMessage, message];
}

class StartListeningEvent extends FollowUpRefinementEvent {
  const StartListeningEvent();
}

class StopListeningEvent extends FollowUpRefinementEvent {
  const StopListeningEvent();
}

class CopyItineraryEvent extends FollowUpRefinementEvent {
  const CopyItineraryEvent();
}

class SaveOfflineEvent extends FollowUpRefinementEvent {
  const SaveOfflineEvent();
}

class RegenerateItineraryEvent extends FollowUpRefinementEvent {
  const RegenerateItineraryEvent();
}

class OpenInMapsEvent extends FollowUpRefinementEvent {
  const OpenInMapsEvent();
}

class ShareItineraryEvent extends FollowUpRefinementEvent {
  const ShareItineraryEvent();
}
