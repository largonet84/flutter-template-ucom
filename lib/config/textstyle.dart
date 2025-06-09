// ignore_for_file: prefer_const_constructors, deprecated_member_use, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static String? primaryColorString = "#4263EB";
  static String? secondaryColorString = "#F5F7FE";
  static bool isLightTheme = true;

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;

  static ThemeData getTheme() {
    if (isLightTheme) {
      return lightTheme();
    } else {
      return darkTheme();
    }
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      titleLarge: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.titleLarge!.color,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      titleMedium: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.titleMedium!.color,
          fontSize: 16,
        ),
      ),
      titleSmall: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.titleSmall!.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      bodyMedium: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.bodyMedium!.color,
          fontSize: 16,
        ),
      ),
      bodyLarge: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.bodyLarge!.color,
          fontSize: 14,
        ),
      ),
      labelLarge: GoogleFonts.ubuntu(
        textStyle: TextStyle(color: base.labelLarge!.color, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      bodySmall: GoogleFonts.ubuntu(
        textStyle: TextStyle(color: base.bodySmall!.color, fontSize: 12),
      ),
      headlineMedium: GoogleFonts.ubuntu(
        textStyle: TextStyle(color: base.headlineMedium!.color, fontSize: 34),
      ),
      displaySmall: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.displaySmall!.color,
          fontSize: 48,
        ),
      ),
      displayMedium: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.displayMedium!.color,
          fontSize: 60,
        ),
      ),
      displayLarge: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.displayLarge!.color,
          fontSize: 96,
        ),
      ),
      headlineSmall: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.headlineSmall!.color,
          fontSize: 24,
        ),
      ),
      labelSmall: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.labelSmall!.color,
          fontSize: 10,
        ),
      ),
    );
  }

  static ThemeData lightTheme() {
    Color primaryColor = HexColor(primaryColorString!);
    Color secondaryColor = HexColor(secondaryColorString!);
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    );

    final ThemeData base = ThemeData.light();
    return base.copyWith(
      appBarTheme: AppBarTheme(color: Colors.white),
      popupMenuTheme: PopupMenuThemeData(color: Colors.white),
      primaryColor: primaryColor,
      splashColor: Colors.white.withOpacity(0.1),
      hoverColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
      highlightColor: Colors.transparent,
      canvasColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.textTheme),
      platform: TargetPlatform.iOS,
      indicatorColor: primaryColor,
      disabledColor: HexColor("#D5D7D8"), colorScheme: colorScheme.copyWith(error: Colors.red).copyWith(background: Colors.white),
    );
  }

  static ThemeData darkTheme() {
    Color primaryColor = HexColor(primaryColorString!);
    Color secondaryColor = HexColor(secondaryColorString!);
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    );
    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      popupMenuTheme: PopupMenuThemeData(color: Colors.black),
      appBarTheme: AppBarTheme(color: Colors.black),
      primaryColor: primaryColor,
      indicatorColor: Colors.white,
      splashColor: Colors.white24,
      splashFactory: InkRipple.splashFactory,
      canvasColor: Colors.white,
      scaffoldBackgroundColor: Colors.grey[850],
      buttonTheme: ButtonThemeData(
        colorScheme: colorScheme,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      platform: TargetPlatform.iOS, colorScheme: colorScheme.copyWith(background: Colors.grey[850]),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
