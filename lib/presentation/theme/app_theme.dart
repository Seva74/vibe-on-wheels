import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF7C5CBF);
  static const Color primaryLight = Color(0xFFB39DDB);
  static const Color primarySurface = Color(0xFFF3EEFF);
  static const Color accent = Color(0xFFE8DEF8);
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textHint = Color(0xFF938F99);
  static const Color surface = Color(0xFFFFFBFE);
  static const Color surfaceVariant = Color(0xFFF7F2FA);
  static const Color divider = Color(0xFFE7E0EC);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFBA1A1A);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: primary,
          onPrimary: Colors.white,
          primaryContainer: accent,
          onPrimaryContainer: Color(0xFF21005D),
          secondary: primaryLight,
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFEADDFF),
          onSecondaryContainer: Color(0xFF21005D),
          tertiary: Color(0xFF7D5260),
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFFFD8E4),
          onTertiaryContainer: Color(0xFF31111D),
          error: error,
          onError: Colors.white,
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF410002),
          surface: surface,
          onSurface: textPrimary,
          surfaceContainerHighest: surfaceVariant,
          onSurfaceVariant: textSecondary,
          outline: Color(0xFF79747E),
          outlineVariant: divider,
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: Color(0xFF313033),
          onInverseSurface: Color(0xFFF4EFF4),
          inversePrimary: Color(0xFFCFBCFF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        cardTheme: const CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: divider, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(color: textHint),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: textHint,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return primary;
            return null;
          }),
        ),
      );
}