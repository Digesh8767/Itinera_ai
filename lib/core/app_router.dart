import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:itinera_ai/core/global.dart';
import 'package:itinera_ai/screen/creating_itinerary/creating_itinerary_screen.dart';
import 'package:itinera_ai/screen/creating_itinerary/bloc/creating_itinerary_bloc.dart';
import 'package:itinera_ai/screen/follow_up_refinement/bloc/follow_up_refinement_bloc.dart';
import 'package:itinera_ai/screen/follow_up_refinement/follow_up_refinement_screen.dart';
import 'package:itinera_ai/screen/home/home_screen.dart';
import 'package:itinera_ai/screen/itinerary_process/bloc/itinerary_process_bloc.dart';
import 'package:itinera_ai/screen/itinerary_process/itinerary_process_screen.dart';
import 'package:itinera_ai/screen/login/login_screen.dart';
import 'package:itinera_ai/screen/profile/profile_screen.dart';
import 'package:itinera_ai/screen/signUp/sign_up_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: Global.navKey,
    initialLocation: LoginScreen.path,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;

      //Define protected routes that require authentication
      final protectedRoutes = [HomeScreen.path];
      final isProtectedRoute = protectedRoutes.contains(state.uri.path);

      // If user is not logged in and trying to access protected route, redirect to login
      if (!isLoggedIn && isProtectedRoute) {
        return LoginScreen.path;
      }

      // If user is logged in and trying to access login or signup, redirect to home
      if (isLoggedIn &&
          [SignupScreen.path, LoginScreen.path].contains(state.uri.path)) {
        return HomeScreen.path;
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: HomeScreen.path,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: SignupScreen.path,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: LoginScreen.path,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: ProfileScreen.path,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: CreatingItineraryScreen.path,
        builder: (context, state) {
          final tripDescription =
              state.uri.queryParameters['description'] ?? '';
          return BlocProvider(
            create: (context) => CreatingItineraryBloc(),
            child: CreatingItineraryScreen(tripDescription: tripDescription),
          );
        },
      ),
      GoRoute(
        path: ItineraryProcessScreen.path,
        builder: (context, state) {
          final description = state.uri.queryParameters['description'] ?? '';
          return BlocProvider(
            create: (context) => ItineraryProcessBloc(),
            child: ItineraryProcessScreen(tripDescription: description),
          );
        },
      ),
      GoRoute(
        path: FollowUpRefinementScreen.path,
        builder: (context, state) {
          final originalPrompt = state.uri.queryParameters['prompt'] ?? '';
          final itineraryJson = state.uri.queryParameters['itinerary'] ?? '{}';
          final itinerary = json.decode(itineraryJson);

          return BlocProvider(
            create: (context) => FollowUpRefinementBloc(
              originalPrompt: originalPrompt,
              currentItinerary: itinerary,
            ),
            child: FollowUpRefinementScreen(
              originalPrompt: originalPrompt,
              currentItinerary: itinerary,
            ),
          );
        },
      ),
    ],
  );
}
