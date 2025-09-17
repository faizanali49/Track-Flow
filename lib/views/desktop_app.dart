// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trackerdesktop/provider/states.dart';
// import 'package:trackerdesktop/theme/colors.dart';
// import 'package:trackerdesktop/theme/theme_check.dart';
// import 'package:trackerdesktop/views/widgets/right_sidebar.dart';
// import 'package:trackerdesktop/provider/theme_check.dart';
// import 'package:trackerdesktop/services/app_state_manager.dart';

// class DesktopApp extends ConsumerStatefulWidget {
//   const DesktopApp({super.key});

//   @override
//   ConsumerState<DesktopApp> createState() => _DesktopAppState();
// }

// class _DesktopAppState extends ConsumerState<DesktopApp> {
//   @override
//   void initState() {
//     super.initState();
//     // Set theme to light mode
//     ref.read(desktopCurrentTheme.notifier).state = false;

//     // This ensures state is restored as early as possible
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       AppStateManager.restoreAppState(ref);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = ref.watch(desktopCurrentTheme);
//     return MaterialApp(
//       theme: ThemeData.light(),
//       darkTheme: ThemeData.dark(),
//       themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: Container(
//           // Use white background color explicitly
//           color: Colors.white,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [Expanded(child: RightSidebar())],
//           ),
//         ),
//       ),
//     );
//   }
// }
