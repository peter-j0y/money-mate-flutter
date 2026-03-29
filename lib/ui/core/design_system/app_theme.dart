import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_semantic_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      error: AppColors.danger,
      surface: AppColors.surface,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimary,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      extensions: const [AppSemanticColors.light],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: TextStyle(color: AppColors.white),
      ),
      dividerColor: AppColors.border,
    );
  }

  static ThemeData get dark {
    const semantic = AppSemanticColors.dark;
    final colorScheme = ColorScheme.dark(
      primary: semantic.primary,
      secondary: semantic.primary,
      error: semantic.danger,
      surface: semantic.surface,
      onPrimary: semantic.inverseText,
      onSecondary: semantic.inverseText,
      onSurface: semantic.textPrimary,
      onError: semantic.inverseText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: semantic.background,
      extensions: const [AppSemanticColors.dark],
      appBarTheme: AppBarTheme(
        backgroundColor: semantic.surface,
        foregroundColor: semantic.textPrimary,
        surfaceTintColor: semantic.overlay,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: semantic.surfaceMuted,
        contentTextStyle: TextStyle(color: semantic.textPrimary),
      ),
      dividerColor: semantic.border,
    );
  }
}
