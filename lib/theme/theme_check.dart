import 'package:flutter/material.dart';
import 'package:trackerdesktop/theme/colors.dart';

// class AppColors {
class AppColor {
  final bool isDarkMode;

  AppColor({required this.isDarkMode});

  Color get primary => isDarkMode ? primaryD : primaryL;
  Color get textColor => isDarkMode ? TextD : TextL;
  Color get secondary =>
      isDarkMode ? const Color.fromARGB(255, 127, 132, 133) : secondaryL;

  Color get backgroundColor =>
      isDarkMode ? const Color.fromARGB(255, 148, 148, 148) : TextL;
  Color get offlinebtn => isDarkMode ? errorD : errorD;
  Color get online => isDarkMode ? onlinebtn : onlinebtn;
  Color get pause => isDarkMode ? pausebtn : pausebtn;
}

// customTextStyle(BuildContext context) {
//   return TextStyle(
//     color: Theme.of(context).textTheme.bodyLarge?.color,
//     fontSize: 16,
//     fontFamily: 'Roboto',
//   );
// }
