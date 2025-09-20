part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String? displayName;
  final String? email;

  const UpdateProfileEvent({
    this.displayName,
    this.email,
  });

  @override
  List<Object> get props => [displayName ?? '', email ?? ''];
}

class LogoutEvent extends ProfileEvent {
  const LogoutEvent();
}

class ResetProfileStateEvent extends ProfileEvent {
  const ResetProfileStateEvent();
}
