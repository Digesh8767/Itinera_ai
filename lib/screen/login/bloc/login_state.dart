part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String message;
  final String userId;
  final String userEmail;

  const LoginSuccess({
    required this.message,
    required this.userId,
    required this.userEmail,
  });

  @override
  List<Object> get props => [message, userId, userEmail];
}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class GoogleLoginSuccess extends LoginState {
  final String message;
  final String userId;
  final String userEmail;

  const GoogleLoginSuccess({
    required this.message,
    required this.userId,
    required this.userEmail,
  });

  @override
  List<Object> get props => [message, userId, userEmail];
}

class GoogleLoginFailure extends LoginState {
  final String message;

  const GoogleLoginFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class ForgotPasswordLoading extends LoginState {}

class ForgotPasswordSuccess extends LoginState {
  final String message;

  const ForgotPasswordSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ForgotPasswordFailure extends LoginState {
  final String message;

  const ForgotPasswordFailure({required this.message});

  @override
  List<Object> get props => [message];
}
