import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardThemeData,
      bottomNavigationBarTheme: _bottomNavigationBarThemeData,
      tabBarTheme: _tabBarThemeData,
      dividerTheme: _dividerThemeData,
      listTileTheme: _listTileThemeData,
      textTheme: _textTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.gray900,
      appBarTheme: _appBarTheme.copyWith(
        backgroundColor: AppColors.gray900,
        foregroundColor: AppColors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme.copyWith(
        fillColor: AppColors.gray800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray700),
        ),
      ),
      cardTheme: _cardThemeData.copyWith(
        color: AppColors.gray800,
      ),
      bottomNavigationBarTheme: _bottomNavigationBarThemeData.copyWith(
        backgroundColor: AppColors.gray900,
      ),
      textTheme: _textTheme.apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
      ),
    );
  }

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.defaultBlue,
    onPrimary: AppColors.white,
    secondary: AppColors.defaultGold,
    onSecondary: AppColors.strongBlue,
    tertiary: AppColors.accentBlue,
    onTertiary: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: AppColors.gray800,
    onInverseSurface: AppColors.gray100,
    inversePrimary: AppColors.accentBlue,
    surfaceTint: AppColors.defaultBlue,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.accentBlue,
    onPrimary: AppColors.white,
    secondary: AppColors.accentGold,
    onSecondary: AppColors.black,
    tertiary: AppColors.subtleBlue,
    onTertiary: AppColors.strongBlue,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.gray800,
    onSurface: AppColors.white,
    surfaceContainerHighest: AppColors.gray700,
    onSurfaceVariant: AppColors.gray300,
    outline: AppColors.gray600,
    outlineVariant: AppColors.gray700,
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: AppColors.gray100,
    onInverseSurface: AppColors.gray800,
    inversePrimary: AppColors.defaultBlue,
    surfaceTint: AppColors.accentBlue,
  );

  static const AppBarTheme _appBarTheme = AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.onBackground,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.onBackground,
      fontFamily: 'Inter',
    ),
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme = 
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.defaultBlue,
      foregroundColor: AppColors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.defaultBlue,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme = 
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.defaultBlue,
      side: const BorderSide(color: AppColors.defaultBlue, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
  );

  static final InputDecorationTheme _inputDecorationTheme = 
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.defaultBlue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: const TextStyle(
      color: AppColors.onSurfaceVariant,
      fontSize: 16,
      fontFamily: 'Inter',
    ),
    labelStyle: const TextStyle(
      color: AppColors.onSurface,
      fontSize: 16,
      fontFamily: 'Inter',
    ),
  );

  static final CardThemeData _cardThemeData = CardThemeData(
    elevation: 0,
    color: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.outlineVariant),
    ),
    margin: EdgeInsets.zero,
  );

  static const BottomNavigationBarThemeData _bottomNavigationBarThemeData = 
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.white,
    selectedItemColor: AppColors.defaultBlue,
    unselectedItemColor: AppColors.onSurfaceVariant,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  static const TabBarThemeData _tabBarThemeData = TabBarThemeData(
    labelColor: AppColors.defaultBlue,
    unselectedLabelColor: AppColors.onSurfaceVariant,
    indicatorColor: AppColors.defaultBlue,
    indicatorSize: TabBarIndicatorSize.tab,
    labelStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontFamily: 'Inter',
    ),
  );

  static const DividerThemeData _dividerThemeData = DividerThemeData(
    color: AppColors.outlineVariant,
    thickness: 1,
    space: 1,
  );

  static const ListTileThemeData _listTileThemeData = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.onBackground,
      fontFamily: 'Inter',
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.onBackground,
      fontFamily: 'Inter',
      height: 1.2,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.onBackground,
      fontFamily: 'Inter',
      height: 1.3,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.onBackground,
      fontFamily: 'Inter',
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.onBackground,
      fontFamily: 'Inter',
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.onBackground,
      fontFamily: 'Inter',
      height: 1.4,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.onBackground,
      fontFamily: 'Inter',
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.onBackground,
      fontFamily: 'Inter',
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.onBackground,
      fontFamily: 'Inter',
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurface,
      fontFamily: 'Inter',
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurface,
      fontFamily: 'Inter',
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurfaceVariant,
      fontFamily: 'Inter',
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurface,
      fontFamily: 'Inter',
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurface,
      fontFamily: 'Inter',
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurfaceVariant,
      fontFamily: 'Inter',
      height: 1.4,
    ),
  );
}