import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const sage = Color(0xFF687F6E);
  static const moss = Color(0xFFA7B8A7);
  static const mist = Color(0xFFD9E1D9);
  static const ivory = Color(0xFFF4EFE8);
  static const sand = Color(0xFFC9BDAF);
  static const card = Color(0xFFFAF7F2);
  static const ink = Color(0xFF2E3A31);
  static const muted = Color(0xFF7A877D);
  static const danger = Color(0xFFB5574B);
  static const dangerTint = Color(0xFFF3DDD8);
  static const pending = Color(0xFFA8793A);
  static const pendingTint = Color(0xFFF1E6D3);
}

class AppShadows {
  // A darker shadow bottom right and a light one top left give the soft raised look
  static const soft = [
    BoxShadow(color: Color(0x33BFB3A2), blurRadius: 18, offset: Offset(6, 8)),
    BoxShadow(color: Color(0xCCFFFFFF), blurRadius: 14, offset: Offset(-6, -6)),
  ];
}

class AppTheme {
    // Applies the Inter font to every text style, one style at a time
  static TextTheme _interTextTheme(TextTheme t) {
    TextStyle? inter(TextStyle? s) =>
        s == null ? null : GoogleFonts.inter(textStyle: s);
    return t.copyWith(
      displayLarge: inter(t.displayLarge),
      displayMedium: inter(t.displayMedium),
      displaySmall: inter(t.displaySmall),
      headlineLarge: inter(t.headlineLarge),
      headlineMedium: inter(t.headlineMedium),
      headlineSmall: inter(t.headlineSmall),
      titleLarge: inter(t.titleLarge),
      titleMedium: inter(t.titleMedium),
      titleSmall: inter(t.titleSmall),
      bodyLarge: inter(t.bodyLarge),
      bodyMedium: inter(t.bodyMedium),
      bodySmall: inter(t.bodySmall),
      labelLarge: inter(t.labelLarge),
      labelMedium: inter(t.labelMedium),
      labelSmall: inter(t.labelSmall),
    );
  }
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.sage).copyWith(
      primary: AppColors.sage,
      onPrimary: AppColors.ivory,
      secondary: AppColors.moss,
      onSecondary: AppColors.ink,
      primaryContainer: AppColors.mist,
      onPrimaryContainer: AppColors.ink,
      surface: AppColors.ivory,
      onSurface: AppColors.ink,
      surfaceTint: Colors.transparent,
      surfaceContainerLow: AppColors.card,
      surfaceContainerHigh: AppColors.card,
      error: AppColors.danger,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
        final textTheme = _interTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    OutlineInputBorder border(Color color, [double width = 1.2]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ivory,
            canvasColor: AppColors.card,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.ink,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          color: AppColors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.mist),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.muted),
        floatingLabelStyle: const TextStyle(color: AppColors.sage),
        prefixIconColor: AppColors.sage,
        suffixIconColor: AppColors.muted,
        border: border(AppColors.mist),
        enabledBorder: border(AppColors.mist),
        focusedBorder: border(AppColors.sage, 1.6),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 1.6),
        disabledBorder: border(AppColors.mist),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: AppColors.ivory,
          disabledBackgroundColor: AppColors.mist,
          disabledForegroundColor: AppColors.muted,
          elevation: 0,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          side: const BorderSide(color: AppColors.sand, width: 1.2),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sage,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.sage
              : AppColors.sand,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.sage,
        foregroundColor: AppColors.ivory,
        elevation: 3,
        shape: const StadiumBorder(),
        extendedTextStyle:
            GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.sage,
        linearTrackColor: AppColors.mist,
      ),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.sage),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: AppColors.ivory),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}