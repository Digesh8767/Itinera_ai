part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class CreateItineraryEvent extends HomeEvent {
  final String tripDescription;

  const CreateItineraryEvent({required this.tripDescription});

  @override
  List<Object> get props => [tripDescription];
}

class LoadSavedItinerariesEvent extends HomeEvent {
  const LoadSavedItinerariesEvent();
}

class DeleteItineraryEvent extends HomeEvent {
  final String itineraryId;

  const DeleteItineraryEvent({required this.itineraryId});

  @override
  List<Object> get props => [itineraryId];
}

class ResetHomeStateEvent extends HomeEvent {
  const ResetHomeStateEvent();
}
