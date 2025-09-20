import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:itinera_ai/screen/home/home_screen.dart';
import 'package:itinera_ai/screen/login/login_screen.dart';
import '../services/firebase_auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({
    super.key,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuthService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
