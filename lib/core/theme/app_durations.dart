import 'package:flutter/material.dart';

class AppDurations {
  static const Duration pageMount = Duration(milliseconds: 500);
  static const Duration miniPlayerPress = Duration(milliseconds: 120);
  static const Duration cardPress = Duration(milliseconds: 150);
  static const Duration rowSwipe = Duration(milliseconds: 280);
  static const Duration miniPlayerProgress = Duration(milliseconds: 300);
  static const Duration panelSlide = Duration(milliseconds: 440);
  static const Duration playerOverlay = Duration(milliseconds: 380);
  static const Duration lyricsExpand = Duration(milliseconds: 440);
  static const Duration lyricsLine = Duration(milliseconds: 300);
  static const Duration bgTransition = Duration(milliseconds: 1200);
  static const Duration toastSlide = Duration(milliseconds: 440);
  static const Duration inputFocus = Duration(milliseconds: 250);
  static const Duration iconPress = Duration(milliseconds: 120);
}

class AppCurves {
  static const Curve standard = Cubic(0.4, 0, 0.2, 1);
  static const Curve ease = Curves.ease;
  static const Curve easeOut = Curves.easeOut;
}
