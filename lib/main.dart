import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'views/desktop_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await windowManager.setResizable(false);
  await windowManager.setMaximumSize(const Size(450, 450));
  // Set the window options
  WindowOptions windowOptions = WindowOptions(
    size: const Size(450, 450),
    center: true,
    // alwaysOnTop: true,
    fullScreen: false,
    // minimumSize: Size(450, 450),
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    // await windowManager.setResizable(false);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: DesktopApp());
  }
}
