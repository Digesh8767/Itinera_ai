import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:itinera_ai/core/global.dart';
import 'package:itinera_ai/screen/home/home_screen.dart';
import 'package:itinera_ai/screen/login/login_screen.dart';
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
    ],
  );
}
