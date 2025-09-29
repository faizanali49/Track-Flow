import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/provider/employee_profile_provider.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/provider/theme_check.dart';
import 'package:trackerdesktop/services/firebase_service.dart';
import 'package:trackerdesktop/services/home_app_state_manager.dart';
import 'package:trackerdesktop/theme/colors.dart';
import 'package:trackerdesktop/views/widgets/display_timer.dart';
import 'package:trackerdesktop/views/widgets/online_dialog_box.dart';
import 'package:trackerdesktop/views/widgets/paused_dialog_box.dart';
import 'package:trackerdesktop/views/widgets/resumed_dialog_box.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final HomeController _controller;
  late final AppLifecycleService _lifecycleService;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _controller = ref.read(homeControllerProvider);
    _lifecycleService = ref.read(appLifecycleServiceProvider);

    _lifecycleService.init();
    _controller.runInitialSetup(context);
  }

  @override
  void dispose() {
    _lifecycleService.dispose();
    super.dispose();
  }

  Widget _actionButton({
    required String label,
    required Color borderColor,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.circle, color: borderColor),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: borderColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(desktopCurrentTheme);
    final onlineTime = ref.watch(onlineTimeProvider);
    final employeemail = ref.watch(employeeEmailProvider);
    final profile = ref.watch(employeeProfileProvider);
    final stopwatchState = ref.watch(stopwatchProvider);
    final isOnline = ref.watch(onlinestatus);
    final isPaused = ref.watch(pausedstatus);

    final String formattedTime = DateFormat('h:mm a').format(DateTime.now());

    // Fixed version - no parsing needed since onlineTime is already formatted
    // String currentTime = DateTime.now().toIso8601String();
    String displayStartTime = DateFormat('h:mm a').format(DateTime.now());

    if (onlineTime != null && onlineTime.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(onlineTime); // parse ISO string
        displayStartTime = DateFormat('h:mm a').format(dateTime);
        // Example output: "5:15 PM"
      } catch (e) {
        debugPrint('Error parsing onlineTime: $e');
      }
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      body: profile.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text(
                'No profile data available.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      isDarkMode
                          ? 'assets/images/scrapy-white.png'
                          : 'assets/images/scrape.png',
                      height: 50,
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(profile.avatarUrl),
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              employeemail ?? 'Guest',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              profile.role,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: () => _controller.signOut(context),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26, width: 1),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Start Time",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            displayStartTime,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              letterSpacing: 1.2,
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Text(
                            "Spend Time",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          displayTimer(context, ref),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        _actionButton(
                          label: "Online",
                          borderColor: isOnline ? Colors.green : Colors.grey,
                          icon: Icons.wifi,
                          onPressed: isOnline
                              ? null
                              : () {
                                  // Get the stopwatch notifier INSTANCE
                                  final stopwatchNotifier = ref.read(
                                    stopwatchProvider.notifier,
                                  );

                                  // Pass the actual instance to onlineAlert
                                  onlineAlert(
                                    context,
                                    ref,
                                    isOnline,
                                    stopwatchState,
                                    stopwatchNotifier, // Instance, not type
                                  );
                                },
                        ),
                        const SizedBox(height: 20),
                        _actionButton(
                          label: isPaused ? "Resume" : "Pause",
                          borderColor: isPaused ? onlinebtn : pausebtn,
                          icon: isPaused ? Icons.play_arrow : Icons.pause,
                          onPressed: isOnline
                              ? () {
                                  // Get the stopwatch notifier INSTANCE
                                  final stopwatchNotifier = ref.read(
                                    stopwatchProvider.notifier,
                                  );

                                  if (isPaused) {
                                    resumeAlert(
                                      context,
                                      ref,
                                      DateFormat(
                                        'h:mm a',
                                      ).format(DateTime.now()),
                                      isOnline,
                                      stopwatchState,
                                      stopwatchNotifier, // Instance, not type
                                    );
                                  } else {
                                    pausedAlert(
                                      context,
                                      ref,
                                      DateFormat(
                                        'h:mm a',
                                      ).format(DateTime.now()),
                                      isOnline,
                                      stopwatchState,
                                      stopwatchNotifier, // Instance, not type
                                    );
                                  }
                                }
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _actionButton(
                          label: "Offline",
                          borderColor: isOnline ? Colors.red : Colors.grey,
                          icon: Icons.power_settings_new,
                          onPressed: isOnline
                              ? () => _controller.goOffline(
                                  context,
                                  formattedTime,
                                  stopwatchState.elapsed,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
