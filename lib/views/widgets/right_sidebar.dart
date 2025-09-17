// lib/views/widgets/right_sidebar.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Add this for navigation
import 'package:intl/intl.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/views/widgets/offline_dialog_box.dart';
import 'package:trackerdesktop/views/widgets/online_dialog_box.dart';
import 'package:trackerdesktop/views/widgets/paused_dialog_box.dart';
import 'package:trackerdesktop/views/widgets/resumed_dialog_box.dart';
import 'package:trackerdesktop/provider/theme_check.dart';
import 'package:trackerdesktop/views/login_authentication/services/web_auth.dart';

class RightSidebar extends ConsumerWidget {
  const RightSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(desktopCurrentTheme);
    final onlineTime = ref.watch(onlineTimeProvider);
    final stopwatchState = ref.watch(stopwatchProvider);
    final stopwatchNotifier = ref.read(stopwatchProvider.notifier);
    final isOnline = ref.watch(onlinestatus);
    final isPaused = ref.watch(pausedstatus);
    final username = ref.watch(userNameProvider);

    // Check if user is authenticated using WebAuthService
    WindowsAuthService().isAuthenticated().then((isAuthenticated) {
      if (!isAuthenticated) {
        // Redirect to login if not authenticated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
      }
    });

    // Use the stored email for username if available
    WindowsAuthService().getUserEmail().then((email) {
      if (email != null && ref.read(userNameProvider) != email) {
        ref.read(userNameProvider.notifier).state = email;
      }
    });

    String formattedTime = DateFormat('h:mm a').format(DateTime.now());

    String formatTime(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(duration.inHours);
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$hours:$minutes:$seconds';
    }

    // Button builder for consistency
    Widget actionButton({
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
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            ),
          ),
        ),
      );
    }

    // Display time properly based on current state
    Widget displayTimer() {
      if (!isOnline) {
        return Text(
          '00:00:00',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        );
      } else {
        return Text(
          formatTime(stopwatchState.elapsed),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isPaused ? Colors.orange : Colors.green,
            letterSpacing: 1.2,
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Row
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
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/circler.jpg'),
                      radius: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Logout button with direct Firebase signout
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await WindowsAuthService().signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
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
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Start Time",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        onlineTime == null ? '--:--:--' : onlineTime.toString(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Spend Time",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      displayTimer(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Column(
                  children: [
                    actionButton(
                      label: "Online",
                      borderColor: isOnline ? Colors.green : Colors.grey,
                      icon: Icons.wifi,
                      onPressed: isOnline
                          ? null
                          : () {
                              onlineAlert(
                                context,
                                ref,
                                isOnline,
                                stopwatchState,
                                stopwatchNotifier,
                              );
                            },
                    ),
                    const SizedBox(height: 20),
                    actionButton(
                      label: isPaused ? "Resume" : "Pause",
                      borderColor: Colors.orange,
                      icon: isPaused ? Icons.play_arrow : Icons.pause,
                      onPressed: isOnline
                          ? () {
                              isPaused
                                  ? resumeAlert(
                                      context,
                                      ref,
                                      formattedTime,
                                      isOnline,
                                      stopwatchState,
                                      stopwatchNotifier,
                                    )
                                  : pausedAlert(
                                      context,
                                      ref,
                                      formattedTime,
                                      isOnline,
                                      stopwatchState,
                                      stopwatchNotifier,
                                    );
                            }
                          : null,
                    ),
                    const SizedBox(height: 20),
                    actionButton(
                      label: "Offline",
                      borderColor: isOnline ? Colors.red : Colors.grey,
                      icon: Icons.power_settings_new,
                      onPressed: isOnline
                          ? () {
                              offlineAlert(
                                context,
                                ref,
                                formattedTime,
                                isOnline,
                                stopwatchState,
                                stopwatchNotifier,
                                stopwatchState.elapsed,
                              );
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
