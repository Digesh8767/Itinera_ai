part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginWithEmailEvent extends LoginEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginWithEmailEvent({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object> get props => [email, password, rememberMe];
}

class LoginWithGoogleEvent extends LoginEvent {
  const LoginWithGoogleEvent();
}

class ForgotPasswordEvent extends LoginEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class ResetLoginStateEvent extends LoginEvent {
  const ResetLoginStateEvent();
}