import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:trackerdesktop/router/routing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackerdesktop/firebase_options.dart';
import 'package:window_manager/window_manager.dart';

// Global provider container for accessing providers outside the widget tree
final ProviderContainer providerContainer = ProviderContainer();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  final logger = Logger();

  // Setup window manager event listeners
  windowManager.setPreventClose(true);

  // Use the correct WindowListener format

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i(
      'Firebase initialized with project: ${DefaultFirebaseOptions.currentPlatform.projectId}',
    );
  } catch (e) {
    logger.e("❌ Firebase initialization error: $e");
  }

  await windowManager.setResizable(false);
  await windowManager.setMaximumSize(const Size(450, 450));

  WindowOptions windowOptions = WindowOptions(
    size: const Size(450, 450),
    center: true,
    fullScreen: false,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Run the app with ProviderScope using the global container
  runApp(
    UncontrolledProviderScope(
      container: providerContainer,
      child: const RootApp(),
    ),
  );
}

// Create a custom WindowListener class
class MyWindowListener extends WindowListener {
  final Function() onWindowCloseCallback;

  MyWindowListener({required this.onWindowCloseCallback});

  @override
  void onWindowClose() => onWindowCloseCallback();
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
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
    );
  }
}
