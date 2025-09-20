part of 'creating_itinerary_bloc.dart';

sealed class CreatingItineraryState extends Equatable {
  const CreatingItineraryState();

  @override
  List<Object> get props => [];

  // Optional streaming text exposed to UI without needing the concrete type
  String? get streamingText => null;
}

class CreatingItineraryInitial extends CreatingItineraryState {}

class CreatingItineraryProgress extends CreatingItineraryState {
  final CreatingStage stage;
  final double progress;

  const CreatingItineraryProgress({
    required this.stage,
    required this.progress,
  });

  @override
  List<Object> get props => [stage, progress];
}

class CreatingItineraryStreaming extends CreatingItineraryState {
  final String partialText;
  final double? progress;

  const CreatingItineraryStreaming({
    required this.partialText,
    this.progress,
  });

  @override
  List<Object> get props => [partialText, progress ?? 0.0];

  @override
  String? get streamingText => partialText;
}

class CreatingItineraryCompleted extends CreatingItineraryState {
  final Map<String, dynamic> itinerary;

  const CreatingItineraryCompleted({required this.itinerary});

  @override
  List<Object> get props => [itinerary];
}

class CreatingItinerarySuccess extends CreatingItineraryState {
  final String message;

  const CreatingItinerarySuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class CreatingItineraryError extends CreatingItineraryState {
  final String message;

  const CreatingItineraryError({required this.message});

  @override
  List<Object> get props => [message];
}
