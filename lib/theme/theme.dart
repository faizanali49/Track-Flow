import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeIsDark = StateProvider<bool>((ref) {
  // Default to light mode
  return true;
});

final isExpanded = StateProvider<int?>((ref) {
  return null;
});

final isVerseExpanded = StateProvider<int?>((ref) {
  return null;
});

final fontChanger = StateProvider<int>((ref) {
  return 18; // Default font size
});
final menukey = StateProvider<GlobalKey<ScaffoldState>>((ref) {
  return GlobalKey<ScaffoldState>();
});
