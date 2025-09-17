import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  // Hive.registerAdapter(TripModelAdapter());
  await Hive.openBox('trips');
  await Hive.openBox('settings');

  runApp(
    MultiBlocProvider(providers: [], child: const ItineraApp())
  );
}

class ItineraApp extends StatelessWidget {
  const ItineraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Itinera AI',
      debugShowCheckedModeBanner: false,
      // theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,
      // routerConfig: AppRouter.router,
    );
  }
}
