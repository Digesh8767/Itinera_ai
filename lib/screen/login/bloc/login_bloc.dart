import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../services/firestore_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<ResetLoginStateEvent>(_onResetLoginState);
    on<ForgotPasswordEvent>(_onForgotPassword);
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(event.email)) {
        emit(LoginFailure(message: 'Invalid email format'));
        return;
      }

      // Validate password length
      if (event.password.length < 6) {
        emit(
          LoginFailure(message: 'Password must be at least 6 characters long'),
        );
        return;
      }

      // Sign in with Firebase
      final UserCredential? userCredential =
          await FirebaseAuthService.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCredential?.user != null) {
        final User user = userCredential!.user!;
        print('✅ Firebase Auth successful for: ${user.email}');

        try {
          // Create or update user profile in Firestore
          await FirestoreService.createUserProfile(
            uid: user.uid,
            email: user.email!,
            displayName: user.displayName,
            photoURL: user.photoURL,
          );
          print('✅ User profile saved to Firestore successfully!');
        } catch (firestoreError) {
          print('❌ Firestore error: $firestoreError');
          // Still emit success for login, but log the Firestore error
        }

        emit(
          LoginSuccess(
            message: 'Login successful',
            userId: user.uid,
            userEmail: user.email!,
          ),
        );
      } else {
        emit(LoginFailure(message: 'Login failed. Please try again.'));
      }
    } catch (e) {
      print('❌ Login error: $e');
      emit(LoginFailure(message: e.toString()));
    }
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      // Sign in with Google
      final UserCredential? userCredential =
          await FirebaseAuthService.signInWithGoogle();

      if (userCredential?.user != null) {
        final User user = userCredential!.user!;

        // Create or update user profile in Firestore
        await FirestoreService.createUserProfile(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoURL: user.photoURL,
        );

        emit(
          GoogleLoginSuccess(
            message: 'Google login successful',
            userId: user.uid,
            userEmail: user.email!,
          ),
        );
      } else {
        emit(GoogleLoginFailure(
            message: 'Google login failed. Please try again.'));
      }
    } catch (e) {
      emit(GoogleLoginFailure(message: e.toString()));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(ForgotPasswordLoading());

    try {
      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(event.email)) {
        emit(
          ForgotPasswordFailure(message: 'Please enter a valid email address'),
        );
        return;
      }

      // Send password reset email
      await FirebaseAuthService.sendPasswordResetEmail(email: event.email);

      emit(
        ForgotPasswordSuccess(
          message: 'Password reset link sent to ${event.email}',
        ),
      );
    } catch (e) {
      emit(ForgotPasswordFailure(message: e.toString()));
    }
  }

  void _onResetLoginState(
    ResetLoginStateEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginInitial());
  }
}
