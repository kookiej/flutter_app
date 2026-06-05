import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle pageTitle = GoogleFonts.notoSerifKr(
    fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white,
    letterSpacing: -0.5,
  );
  static TextStyle sectionTitle = GoogleFonts.notoSerifKr(
    fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white,
    letterSpacing: -0.3,
  );
  static TextStyle songTitleLarge = GoogleFonts.notoSerifKr(
    fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
    letterSpacing: -0.5, height: 1.2,
  );
  static TextStyle songTitleMid = GoogleFonts.notoSerifKr(
    fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
    letterSpacing: -0.3, height: 1.3,
  );
  static TextStyle miniPlayerTitle = GoogleFonts.notoSerifKr(
    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
  );
  static TextStyle loginTitle = GoogleFonts.notoSerifKr(
    fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white,
    letterSpacing: -0.5,
  );
  static TextStyle loginSubtitle = GoogleFonts.notoSerifKr(
    fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
    letterSpacing: -0.3,
  );

  static TextStyle body = GoogleFonts.notoSansKr(
    fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white,
  );
  static TextStyle bodyLight = GoogleFonts.notoSansKr(
    fontSize: 14, fontWeight: FontWeight.w300, color: AppColors.textSecondary,
  );
  static TextStyle caption = GoogleFonts.notoSansKr(
    fontSize: 12, fontWeight: FontWeight.w300, color: AppColors.textQuaternary,
  );
  static TextStyle artistLabel = GoogleFonts.notoSansKr(
    fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textTertiary,
  );

  static TextStyle monoLabel = GoogleFonts.dmMono(
    fontSize: 10, fontWeight: FontWeight.w400,
    color: AppColors.textMuted, letterSpacing: 2.5,
  );
  static TextStyle monoTime = GoogleFonts.dmMono(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textQuaternary, letterSpacing: 0.5,
  );
  static TextStyle monoIndex = GoogleFonts.dmMono(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textFaint,
  );
  static TextStyle navLabel = GoogleFonts.notoSansKr(
    fontSize: 10, fontWeight: FontWeight.w300, letterSpacing: 0.3,
  );
}
