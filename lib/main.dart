import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:trackerdesktop/router/routing.dart';
import 'package:window_manager/window_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackerdesktop/firebase_options.dart';

// GoRouter configuration

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  final logger = Logger();

  try {
    // Make sure this uses the correct options file for TrackerApp
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Add this to verify which project you're connected to
    logger.i(
      'Firebase initialized with project: ${DefaultFirebaseOptions.currentPlatform.projectId}',
    );
  } catch (e) {
    logger.e("❌ Firebase initialization error: $e");
  }

  await windowManager.setResizable(false);
  await windowManager.setMaximumSize(const Size(450, 450));

  // Set the window options
  WindowOptions windowOptions = WindowOptions(
    size: const Size(450, 450),
    center: true,
    fullScreen: false,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          final router = ref.watch(routerProvider);
          return MaterialApp.router(
            title: 'Employee Tracker',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            themeMode: ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
