import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itinera_ai/services/firebase_auth_service.dart';
import 'package:itinera_ai/services/firestore_service.dart';

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
    emit(GoogleSignupLoading());

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

      // create account with firebase
      final UserCredential? userCredential =
          await FirebaseAuthService.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCredential?.user != null) {
        final user = userCredential!.user!;

        // Create user profile in Firestore
        await FirestoreService.createUserProfile(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoURL: user.photoURL,
        );

        // Mock successful signup
        emit(
          SignupSuccess(
            message: 'Account created successfully!',
            userId: user.uid,
          ),
        );
      } else {
        emit(SignupFailure(
            message: 'Account creation failed. Please try again.'));
      }
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
    emit(GoogleSignupLoading());

    try {
      // Simulate Google signup
      final UserCredential? userCredential =
          await FirebaseAuthService.signInWithGoogle();

      if (userCredential?.user != null) {
        final user = userCredential!.user!;

        // Create user profile in Firestore
        await FirestoreService.createUserProfile(
            uid: user.uid,
            email: user.email!,
            displayName: user.displayName,
            photoURL: user.photoURL);

        // Mock successful Google signup
        emit(
          GoogleSignupSuccess(
            message: 'Google signup successful!',
            userId: user.uid,
          ),
        );
      } else {
        emit(GoogleSignupFailure(
            message: 'Google signup failed. Please try again.'));
      }
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
