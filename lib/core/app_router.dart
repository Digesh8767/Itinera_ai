import 'package:go_router/go_router.dart';
import 'package:itinera_ai/screen/login/login_screen.dart';
import 'package:itinera_ai/screen/signUp/sign_up.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/sign-up-screen',
    routes: [
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
