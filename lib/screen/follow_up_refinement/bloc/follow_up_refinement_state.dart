part of 'follow_up_refinement_bloc.dart';

abstract class FollowUpRefinementState extends Equatable {
  const FollowUpRefinementState();

  @override
  List<Object> get props => [];
}

class FollowUpRefinementInitial extends FollowUpRefinementState {}

class FollowUpRefinementLoaded extends FollowUpRefinementState {
  final List<Map<String, dynamic>> conversationHistory;
  final Map<String, dynamic> currentItinerary;
  final String originalPrompt;

  const FollowUpRefinementLoaded({
    required this.conversationHistory,
    required this.currentItinerary,
    required this.originalPrompt,
  });

  @override
  List<Object> get props =>
      [conversationHistory, currentItinerary, originalPrompt];
}

class FollowUpRefinementLoading extends FollowUpRefinementState {}

class FollowUpRefinementSuccess extends FollowUpRefinementState {
  final String message;

  const FollowUpRefinementSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class FollowUpRefinementError extends FollowUpRefinementState {
  final String message;

  const FollowUpRefinementError({required this.message});

  @override
  List<Object> get props => [message];
}

class ListeningState extends FollowUpRefinementState {
  final bool isListening;

  const ListeningState({required this.isListening});

  @override
  List<Object> get props => [isListening];
}

class CopySuccessState extends FollowUpRefinementState {
  final String message;

  const CopySuccessState({required this.message});

  @override
  List<Object> get props => [message];
}

class SaveOfflineSuccessState extends FollowUpRefinementState {
  final String message;

  const SaveOfflineSuccessState({required this.message});

  @override
  List<Object> get props => [message];
}
