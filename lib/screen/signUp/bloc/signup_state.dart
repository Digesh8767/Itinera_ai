part of 'signup_bloc.dart';

sealed class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object> get props => [];
}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {
  final String message;
  final String userId;

  const SignupSuccess({required this.message, required this.userId});

  @override
  List<Object> get props => [message, userId];
}

class SignupFailure extends SignupState {
  final String message;

  const SignupFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class GoogleSignupSuccess extends SignupState {
  final String message;
  final String userId;

  const GoogleSignupSuccess({required this.message, required this.userId});

  @override
  List<Object> get props => [message, userId];
}

class GoogleSignupFailure extends SignupState {
  final String message;
  const GoogleSignupFailure({required this.message});

  @override
  List<Object> get props => [message];
}
