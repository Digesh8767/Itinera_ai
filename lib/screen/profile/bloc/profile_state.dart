part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String displayName;
  final String email;
  final int requestTokens;
  final int maxRequestTokens;
  final int responseTokens;
  final int maxResponseTokens;
  final double totalCost;

  const ProfileLoaded({
    required this.displayName,
    required this.email,
    required this.requestTokens,
    required this.maxRequestTokens,
    required this.responseTokens,
    required this.maxResponseTokens,
    required this.totalCost,
  });

  @override
  List<Object> get props => [
        displayName,
        email,
        requestTokens,
        maxRequestTokens,
        responseTokens,
        maxResponseTokens,
        totalCost,
      ];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;

  const ProfileUpdateSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ProfileUpdateFailed extends ProfileState {
  final String message;

  const ProfileUpdateFailed({required this.message});

  @override
  List<Object> get props => [message];
}

class LogoutSuccess extends ProfileState {
  const LogoutSuccess();
}

class LogoutFailed extends ProfileState {
  final String message;

  const LogoutFailed({required this.message});

  @override
  List<Object> get props => [message];
}
