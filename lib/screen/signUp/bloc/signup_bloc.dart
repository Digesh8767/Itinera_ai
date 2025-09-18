import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupInitial()) {
    on<SignupWithEmailEvent>(_onSignupWithEmail);
    on<SignupWithGoogleEvent>(_onSignupWithGoogle);
    on<ResetSignupStateEvent>(_onResetSignupState);
  }

  Future<void> _onSignupWithEmail(
    SignupWithEmailEvent event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());

    try {
      // Validate passwords match
      if (event.password != event.confirmPassword) {
        emit(SignupFailure(message: 'Passwords do not match'));
        return;
      }

      // Validate password length
      if (event.password.length < 6) {
        emit(SignupFailure(message: 'Password must be at least 6 characters'));
        return;
      }

      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(event.email)) {
        emit(SignupFailure(message: 'Please enter a valid email address'));
        return;
      }

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Mock successful signup
      emit(
        SignupSuccess(
          message: 'Account created successfully!',
          userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
    } catch (e) {
      emit(
        SignupFailure(message: 'An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  Future<void> _onSignupWithGoogle(
    SignupWithGoogleEvent event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());

    try {
      // Simulate Google signup
      await Future.delayed(Duration(seconds: 2));

      // Mock successful Google signup
      emit(
        GoogleSignupSuccess(
          message: 'Google signup successful!',
          userId: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
    } catch (e) {
      emit(
        GoogleSignupFailure(message: 'Google signup Failed: ${e.toString()}'),
      );
    }
  }

  void _onResetSignupState(
    ResetSignupStateEvent event,
    Emitter<SignupState> emit,
  ) {
    emit(SignupInitial());
    
  }
}
