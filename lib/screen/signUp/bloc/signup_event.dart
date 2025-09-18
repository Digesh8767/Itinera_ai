part of 'signup_bloc.dart';

sealed class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

class SignupWithEmailEvent extends SignupEvent {
  final String email;
  final String password;
  final String confirmPassword;

  const SignupWithEmailEvent({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [email, password, confirmPassword];
}

class SignupWithGoogleEvent extends SignupEvent {
  const SignupWithGoogleEvent();
}

class ResetSignupStateEvent extends SignupEvent {
  const ResetSignupStateEvent();
}
