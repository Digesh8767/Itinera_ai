import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:itinera_ai/services/firebase_auth_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<LogoutEvent>(_onLogout);
    on<ResetProfileStateEvent>(_onResetProfileState);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final user = FirebaseAuthService.currentUser;
      if (user != null) {
        // Mock data - replace with actual data from Firestore
        emit(ProfileLoaded(
          displayName: user.displayName ?? 'User',
          email: user.email ?? '',
          requestTokens: 100,
          maxRequestTokens: 1000,
          responseTokens: 75,
          maxResponseTokens: 1000,
          totalCost: 0.07,
        ));
      } else {
        emit(const ProfileLoaded(
          displayName: 'User',
          email: '',
          requestTokens: 0,
          maxRequestTokens: 1000,
          responseTokens: 0,
          maxResponseTokens: 1000,
          totalCost: 0.0,
        ));
      }
    } catch (e) {
      emit(ProfileUpdateFailed(
          message: 'Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await FirebaseAuthService.updateProfile(
        displayName: event.displayName,
      );

      emit(
          const ProfileUpdateSuccess(message: 'Profile updated successfully!'));

      // Reload profile data
      add(const LoadProfileEvent());
    } catch (e) {
      emit(ProfileUpdateFailed(
          message: 'Failed to update profile: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await FirebaseAuthService.signOut();
      emit(const LogoutSuccess());
    } catch (e) {
      emit(LogoutFailed(message: 'Failed to logout: ${e.toString()}'));
    }
  }

  void _onResetProfileState(
    ResetProfileStateEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(ProfileInitial());
  }
}
