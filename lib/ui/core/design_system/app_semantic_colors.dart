import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.primary,
    required this.danger,
    required this.success,
    required this.warning,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.overlay,
    required this.inverseText,
  });

  final Color primary;
  final Color danger;
  final Color success;
  final Color warning;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color overlay;
  final Color inverseText;

  static const AppSemanticColors light = AppSemanticColors(
    primary: AppColors.hexFF137FEC,
    danger: AppColors.hexFFF43F5E,
    success: AppColors.hexFF10B981,
    warning: AppColors.hexFFF59E0B,
    background: AppColors.hexFFF8FAFC,
    surface: AppColors.white,
    surfaceMuted: AppColors.hexFFF1F5F9,
    textPrimary: AppColors.hexFF0F172A,
    textSecondary: AppColors.hexFF64748B,
    textTertiary: AppColors.hexFF94A3B8,
    border: AppColors.hexFFE2E8F0,
    overlay: AppColors.transparent,
    inverseText: AppColors.white,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    primary: Color(0xFF60A5FA),
    danger: Color(0xFFFB7185),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    background: Color(0xFF0B1220),
    surface: Color(0xFF111827),
    surfaceMuted: Color(0xFF1F2937),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    textTertiary: Color(0xFF94A3B8),
    border: Color(0xFF334155),
    overlay: Colors.transparent,
    inverseText: Color(0xFF0B1220),
  );

  @override
  AppSemanticColors copyWith({
    Color? primary,
    Color? danger,
    Color? success,
    Color? warning,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? overlay,
    Color? inverseText,
  }) {
    return AppSemanticColors(
      primary: primary ?? this.primary,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      overlay: overlay ?? this.overlay,
      inverseText: inverseText ?? this.inverseText,
    );
  }

  @override
  AppSemanticColors lerp(
    ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) {
      return this;
    }
    return AppSemanticColors(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t) ?? surfaceMuted,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textTertiary:
          Color.lerp(textTertiary, other.textTertiary, t) ?? textTertiary,
      border: Color.lerp(border, other.border, t) ?? border,
      overlay: Color.lerp(overlay, other.overlay, t) ?? overlay,
      inverseText: Color.lerp(inverseText, other.inverseText, t) ?? inverseText,
    );
  }
}

extension AppSemanticColorsX on BuildContext {
  AppSemanticColors get appColors {
    return Theme.of(this).extension<AppSemanticColors>() ??
        AppSemanticColors.light;
  }
}
