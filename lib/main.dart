import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itinera_ai/core/app_router.dart';
import 'package:itinera_ai/core/app_theme.dart';
import 'package:itinera_ai/screen/signUp/bloc/signup_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // Initialize Hive for local storage
  // await Hive.initFlutter();
  // Hive.registerAdapter(TripModelAdapter());
  // await Hive.openBox('trips');
  // await Hive.openBox('settings');

  runApp(const ItineraApp());
}

class ItineraApp extends StatelessWidget {
  const ItineraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<SignupBloc>(create: (context) => SignupBloc())],
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
