import 'package:flutter/material.dart';
 

abstract class ThemeColors {
  /// Primary  #5865F2
  static const primary       = Color(0xFF5865F2);
  static const primaryLight  = Color(0xFF7B86F5);
  static const primaryDim    = Color(0xFF1E2260);
 
  /// Secondary  #2B2D31  
  static const secondary     = Color(0xFF2B2D31);
  static const secondaryDim  = Color(0xFF1E2025);
 
  /// Tertiary  #BB5A00  
  static const tertiary      = Color(0xFFBB5A00);
  static const tertiaryLight = Color(0xFFD4720A);
  static const tertiaryDim   = Color(0xFF3D1E00);
 
  /// Neutral  #313338  
  static const neutral       = Color(0xFF313338);
  static const neutralLight  = Color(0xFF4E5058);
 
  static const background    = Color(0xFF1A1B1E);
  static const surface       = Color(0xFF2B2D31); 
  static const surfaceAlt    = Color(0xFF232428); 
  static const surfaceDim    = Color(0xFF1E1F22); 
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB5BAC1);
  static const textTertiary  = Color(0xFF6D6F78);
  static const textAccent    = Color(0xFF5865F2);
  static const liveGreen = Color(0xFF3DDC97);
  static const errorRed  = Color(0xFFED4245);
  static const borderSubtle = Color(0xFF3B3D45);
  static const borderFocus  = Color(0xFF5865F2);
}
 
abstract class ThemeTextStyles {
  static const _headline = TextStyle(fontFamily: 'Manrope', color: ThemeColors.textPrimary, letterSpacing: 0);
 
  static final display        = _headline.copyWith(fontSize: 28, fontWeight: FontWeight.w800, height: 1.25);
  static final headlineLarge  = _headline.copyWith(fontSize: 24, fontWeight: FontWeight.w700);
  static final headlineMedium = _headline.copyWith(fontSize: 20, fontWeight: FontWeight.w700);
  static final headlineSmall  = _headline.copyWith(fontSize: 17, fontWeight: FontWeight.w600);
  static final statNumber     = _headline.copyWith(fontSize: 28, fontWeight: FontWeight.w700);
  static final cardTitle      = _headline.copyWith(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2);
  static final time           = _headline.copyWith(fontSize: 22, fontWeight: FontWeight.w700);
 
  static const _body = TextStyle(fontFamily: 'Inter', color: ThemeColors.textPrimary, letterSpacing: 0);
 
  static final bodyLarge  = _body.copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static final bodyMedium = _body.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: ThemeColors.textSecondary);
  static final bodySmall  = _body.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: ThemeColors.textSecondary);
 
  static final labelCaps   = _body.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2.0, color: ThemeColors.textSecondary);
  static final labelLarge  = _body.copyWith(fontSize: 14, fontWeight: FontWeight.w600);
  static final labelMedium = _body.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeColors.textSecondary);
  static final labelSmall  = _body.copyWith(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: ThemeColors.textSecondary);
  static final button      = _body.copyWith(fontSize: 15, fontWeight: FontWeight.w600);
}
 
abstract class ThemeButtonStyles {
  static const _shape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14)));
  static const _size  = Size.fromHeight(48);
 
  static final primary = ElevatedButton.styleFrom(
    backgroundColor: ThemeColors.primary,
    foregroundColor: ThemeColors.textPrimary,
    disabledBackgroundColor: ThemeColors.primaryDim,
    disabledForegroundColor: ThemeColors.primaryLight,
    elevation: 0, shadowColor: Colors.transparent,
    minimumSize: _size, shape: _shape,
    textStyle: ThemeTextStyles.button,
  );
 

  static final secondary = ElevatedButton.styleFrom(
    backgroundColor: ThemeColors.surfaceAlt,
    foregroundColor: ThemeColors.textPrimary,
    elevation: 0, shadowColor: Colors.transparent,
    minimumSize: _size, shape: _shape,
    textStyle: ThemeTextStyles.button,
  );
 
  static final inverted = ElevatedButton.styleFrom(
    backgroundColor: ThemeColors.textPrimary,
    foregroundColor: ThemeColors.primary,
    elevation: 0, shadowColor: Colors.transparent,
    minimumSize: _size, shape: _shape,
    textStyle: ThemeTextStyles.button,
  );
 
  static final outlined = OutlinedButton.styleFrom(
    foregroundColor: ThemeColors.textPrimary,
    side: const BorderSide(color: ThemeColors.borderSubtle, width: 1),
    minimumSize: _size, shape: _shape,
    textStyle: ThemeTextStyles.button,
  );
 
  static final tertiary = ElevatedButton.styleFrom(
    backgroundColor: ThemeColors.tertiary,
    foregroundColor: ThemeColors.textPrimary,
    elevation: 0, shadowColor: Colors.transparent,
    minimumSize: _size, shape: _shape,
    textStyle: ThemeTextStyles.button,
  );
}
 

ThemeData appTheme() { 
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
    brightness: Brightness.dark,
 
    surface:                 ThemeColors.surface,
    surfaceContainerHighest: ThemeColors.surfaceAlt,
    surfaceDim:              ThemeColors.surfaceDim,
    surfaceContainer:        ThemeColors.secondary,
 
    primary:             ThemeColors.primary,
    onPrimary:           ThemeColors.textPrimary,
    primaryContainer:    ThemeColors.primaryDim,
    onPrimaryContainer:  ThemeColors.primaryLight,
 
    secondary:              ThemeColors.secondary,
    onSecondary:            ThemeColors.textPrimary,
    secondaryContainer:     ThemeColors.secondaryDim,
    onSecondaryContainer:   ThemeColors.textSecondary,
 
    tertiary:              ThemeColors.tertiary,
    onTertiary:            ThemeColors.textPrimary,
    tertiaryContainer:     ThemeColors.tertiaryDim,
    onTertiaryContainer:   ThemeColors.tertiaryLight,
 
    error:   ThemeColors.errorRed,
    onError: ThemeColors.textPrimary,
 
    onSurface:        ThemeColors.textPrimary,
    onSurfaceVariant: ThemeColors.textSecondary,
 
    outline:        ThemeColors.borderSubtle,
    outlineVariant: ThemeColors.neutral,
  ),
    scaffoldBackgroundColor: ThemeColors.background,
 
    // ── Typography ──────────────────────────────
    textTheme: TextTheme(
      displayLarge:   ThemeTextStyles.display,
      headlineLarge:  ThemeTextStyles.headlineLarge,
      headlineMedium: ThemeTextStyles.headlineMedium,
      headlineSmall:  ThemeTextStyles.headlineSmall,
      titleLarge:     ThemeTextStyles.headlineSmall,
      titleMedium:    ThemeTextStyles.labelLarge,
      titleSmall:     ThemeTextStyles.labelMedium,
      bodyLarge:      ThemeTextStyles.bodyLarge,
      bodyMedium:     ThemeTextStyles.bodyMedium,
      bodySmall:      ThemeTextStyles.bodySmall,
      labelLarge:     ThemeTextStyles.labelLarge,
      labelMedium:    ThemeTextStyles.labelMedium,
      labelSmall:     ThemeTextStyles.labelSmall,
    ),
 
    // ── Cards ────────────────────────────────────
    cardTheme: CardThemeData(
      color: ThemeColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: ThemeColors.borderSubtle, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
 
    // ── Buttons ──────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(style: ThemeButtonStyles.primary),
    outlinedButtonTheme: OutlinedButtonThemeData(style: ThemeButtonStyles.outlined),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: ThemeColors.primary, textStyle: ThemeTextStyles.button),
    ),
 
    // ── FAB (tertiary orange) ────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ThemeColors.tertiary,
      foregroundColor: ThemeColors.textPrimary,
      elevation: 0, focusElevation: 0, hoverElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
 
    // ── Chip ─────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: ThemeColors.primaryDim,
      selectedColor: ThemeColors.primary,
      labelStyle: ThemeTextStyles.labelMedium.copyWith(color: ThemeColors.primaryLight),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
 
    // ── Bottom Navigation Bar ────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ThemeColors.surface,
      selectedItemColor: ThemeColors.primary,
      unselectedItemColor: ThemeColors.neutralLight,
      selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
      unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
 
    // ── NavigationBar (M3) ───────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ThemeColors.surface,
      indicatorColor: ThemeColors.primaryDim,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
          ? const IconThemeData(color: ThemeColors.primary, size: 24)
          : const IconThemeData(color: ThemeColors.neutralLight, size: 24)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
          ? const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: ThemeColors.primary)
          : const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, fontFamily: 'Inter', color: ThemeColors.neutralLight)),
    ),
 
    // ── AppBar ───────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: ThemeColors.background,
      foregroundColor: ThemeColors.textPrimary,
      elevation: 0, scrolledUnderElevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontFamily: 'Manrope', fontSize: 17, fontWeight: FontWeight.w700, color: ThemeColors.textPrimary),
      iconTheme: IconThemeData(color: ThemeColors.textSecondary),
    ),
 
    // ── Input ────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ThemeColors.surfaceAlt,
      hintStyle: const TextStyle(color: ThemeColors.textTertiary, fontFamily: 'Inter', fontSize: 14),
      labelStyle: const TextStyle(color: ThemeColors.textSecondary, fontFamily: 'Inter', fontSize: 14),
      prefixIconColor: ThemeColors.textTertiary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeColors.borderSubtle, width: 0.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeColors.borderSubtle, width: 0.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeColors.borderFocus, width: 1.5)),
    ),
 
    // ── Divider ──────────────────────────────────
    dividerTheme: const DividerThemeData(color: ThemeColors.borderSubtle, thickness: 0.5, space: 0),
 
    // ── Icon ─────────────────────────────────────
    iconTheme: const IconThemeData(color: ThemeColors.textSecondary, size: 22),
 
    // ── Progress ─────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ThemeColors.primary,
      linearTrackColor: ThemeColors.primaryDim,
    ),
 
    // ── Switch / Checkbox / Radio ────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? ThemeColors.primary : ThemeColors.neutralLight),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? ThemeColors.primaryDim : ThemeColors.neutral),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? ThemeColors.primary : Colors.transparent),
      checkColor: WidgetStateProperty.all(ThemeColors.textPrimary),
      side: const BorderSide(color: ThemeColors.borderSubtle, width: 1.5),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? ThemeColors.primary : ThemeColors.neutralLight),
    ),
 
    // ── Snackbar ─────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ThemeColors.surfaceAlt,
      contentTextStyle: ThemeTextStyles.bodyMedium.copyWith(color: ThemeColors.textPrimary),
      actionTextColor: ThemeColors.primaryLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
 
    splashColor: ThemeColors.primaryDim,
    highlightColor: Colors.transparent,
    focusColor: ThemeColors.primaryDim,
  );
}
 