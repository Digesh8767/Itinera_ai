part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class ItineraryCreating extends HomeState {}

class ItineraryCreated extends HomeState {
  final String itinerary;
  final String message;

  const ItineraryCreated({
    required this.itinerary,
    required this.message,
  });

  @override
  List<Object> get props => [itinerary, message];
}

class ItineraryCreationFailed extends HomeState {
  final String message;

  const ItineraryCreationFailed({required this.message});

  @override
  List<Object> get props => [message];
}

class SavedItinerariesLoaded extends HomeState {
  final List<Map<String, dynamic>> itineraries;

  const SavedItinerariesLoaded({required this.itineraries});

  @override
  List<Object> get props => [itineraries];
}

class ItineraryDeleted extends HomeState {
  final String message;

  const ItineraryDeleted({required this.message});

  @override
  List<Object> get props => [message];
}
