import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:itinera_ai/core/app_router.dart';
import 'package:itinera_ai/core/app_theme.dart';
import 'package:itinera_ai/screen/home/bloc/home_bloc.dart';
import 'package:itinera_ai/screen/login/bloc/login_bloc.dart';
import 'package:itinera_ai/screen/signUp/bloc/signup_bloc.dart';
import 'package:itinera_ai/services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Google Sign-In (v7+) before any usage
  // If you have a web client id or server client id, pass it here
  // e.g., await GoogleSignIn.instance.initialize(clientId: 'YOUR_CLIENT_ID');

  // // Initialize Hive for local storage
  // await Hive.initFlutter();
  // Hive.registerAdapter(TripModelAdapter());
  // await Hive.openBox('trips');
  // await Hive.openBox('settings');

  // Initialize Google Sign-In with Web Client ID
  if (!kIsWeb) {
    await GoogleSignIn.instance.initialize(
        serverClientId:
            "440298503063-eb7ltt4dcu5mij4l1ei7s3d0vav7keeo.apps.googleusercontent.com");
  }
  runApp(const ItineraApp());
}

class ItineraApp extends StatelessWidget {
  const ItineraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SignupBloc>(create: (context) => SignupBloc()),
        BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Itinera AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
