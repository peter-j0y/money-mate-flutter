import 'package:flutter/material.dart';

/// 프로젝트 전역 색상 토큰
/// - 모든 실제 사용 색상(HEX/RGBO/기본 Colors)을 수집해 한 곳에서 관리합니다.
class AppColors {
  const AppColors._();

  // Base
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;

  // Semantic Aliases
  static const Color primary = Color(0xFF137FEC);
  static const Color danger = Color(0xFFF43F5E);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color overlay = Colors.transparent;
  static const Color inverseText = Colors.white;

  // Hex Tokens
  static const Color hexFFFFFFFF = Color(0xFFFFFFFF);
  static const Color hexFF0F172A = Color(0xFF0F172A);
  static const Color hexFF10B981 = Color(0xFF10B981);
  static const Color hexFF137FEC = Color(0xFF137FEC);
  static const Color hexFF14B8A6 = Color(0xFF14B8A6);
  static const Color hexFF1E293B = Color(0xFF1E293B);
  static const Color hexFF22C55E = Color(0xFF22C55E);
  static const Color hexFF2D6A4F = Color(0xFF2D6A4F);
  static const Color hexFF334155 = Color(0xFF334155);
  static const Color hexFF34D399 = Color(0xFF34D399);
  static const Color hexFF38BDF8 = Color(0xFF38BDF8);
  static const Color hexFF3B82F6 = Color(0xFF3B82F6);
  static const Color hexFF475569 = Color(0xFF475569);
  static const Color hexFF4A4A4A = Color(0xFF4A4A4A);
  static const Color hexFF4D545E = Color(0xFF4D545E);
  static const Color hexFF6366F1 = Color(0xFF6366F1);
  static const Color hexFF64748B = Color(0xFF64748B);
  static const Color hexFF7C3AED = Color(0xFF7C3AED);
  static const Color hexFF8C8C8C = Color(0xFF8C8C8C);
  static const Color hexFF94A3B8 = Color(0xFF94A3B8);
  static const Color hexFF98A0B4 = Color(0xFF98A0B4);
  static const Color hexFF9CA3AF = Color(0xFF9CA3AF);
  static const Color hexFFA78BFA = Color(0xFFA78BFA);
  static const Color hexFFA855F7 = Color(0xFFA855F7);
  static const Color hexFFB8F2E6 = Color(0xFFB8F2E6);
  static const Color hexFFCBD5E1 = Color(0xFFCBD5E1);
  static const Color hexFFCCFBF1 = Color(0xFFCCFBF1);
  static const Color hexFFD97706 = Color(0xFFD97706);
  static const Color hexFFDBEAFE = Color(0xFFDBEAFE);
  static const Color hexFFDCFCE7 = Color(0xFFDCFCE7);
  static const Color hexFFDDEAF6 = Color(0xFFDDEAF6);
  static const Color hexFFE0F2FE = Color(0xFFE0F2FE);
  static const Color hexFFE2E8F0 = Color(0xFFE2E8F0);
  static const Color hexFFE5E7EB = Color(0xFFE5E7EB);
  static const Color hexFFEC4899 = Color(0xFFEC4899);
  static const Color hexFFECFDF5 = Color(0xFFECFDF5);
  static const Color hexFFEEF2FF = Color(0xFFEEF2FF);
  static const Color hexFFEF4444 = Color(0xFFEF4444);
  static const Color hexFFF1F5F9 = Color(0xFFF1F5F9);
  static const Color hexFFF3E8FF = Color(0xFFF3E8FF);
  static const Color hexFFF3F4F6 = Color(0xFFF3F4F6);
  static const Color hexFFF43F5E = Color(0xFFF43F5E);
  static const Color hexFFF59E0B = Color(0xFFF59E0B);
  static const Color hexFFF8FAFC = Color(0xFFF8FAFC);
  static const Color hexFFF97316 = Color(0xFFF97316);
  static const Color hexFFF9FAFB = Color(0xFFF9FAFB);
  static const Color hexFFFACC15 = Color(0xFFFACC15);
  static const Color hexFFFB7185 = Color(0xFFFB7185);
  static const Color hexFFFB923C = Color(0xFFFB923C);
  static const Color hexFFFCE7F3 = Color(0xFFFCE7F3);
  static const Color hexFFFEF2F2 = Color(0xFFFEF2F2);
  static const Color hexFFFEF3C7 = Color(0xFFFEF3C7);
  static const Color hexFFFEF9C3 = Color(0xFFFEF9C3);
  static const Color hexFFFFE4E6 = Color(0xFFFFE4E6);
  static const Color hexFFFFE69A = Color(0xFFFFE69A);
  static const Color hexFFFFEDD5 = Color(0xFFFFEDD5);
  static const Color hexFFFFF1F2 = Color(0xFFFFF1F2);
  static const Color hexFFFFFBEB = Color(0xFFFFFBEB);

  // RGBO Tokens
  static const Color rgba_0_0_0_005 = Color.fromRGBO(0, 0, 0, 0.05);
  static const Color rgba_19_127_236_005 = Color.fromRGBO(19, 127, 236, 0.05);
  static const Color rgba_19_127_236_025 = Color.fromRGBO(19, 127, 236, 0.25);
  static const Color rgba_209_250_229_03 = Color.fromRGBO(209, 250, 229, 0.3);
  static const Color rgba_224_242_254_03 = Color.fromRGBO(224, 242, 254, 0.3);
  static const Color rgba_255_255_255_0 = Color.fromRGBO(255, 255, 255, 0);
  static const Color rgba_255_255_255_05 = Color.fromRGBO(255, 255, 255, 0.5);
  static const Color rgba_255_255_255_09 = Color.fromRGBO(255, 255, 255, 0.9);

  // 전체 팔레트 순회가 필요할 때 사용
  static const List<Color> all = [
    white,
    transparent,
    hexFFFFFFFF,
    hexFF0F172A,
    hexFF10B981,
    hexFF137FEC,
    hexFF14B8A6,
    hexFF1E293B,
    hexFF22C55E,
    hexFF2D6A4F,
    hexFF334155,
    hexFF34D399,
    hexFF38BDF8,
    hexFF3B82F6,
    hexFF475569,
    hexFF4A4A4A,
    hexFF4D545E,
    hexFF6366F1,
    hexFF64748B,
    hexFF7C3AED,
    hexFF8C8C8C,
    hexFF94A3B8,
    hexFF98A0B4,
    hexFF9CA3AF,
    hexFFA78BFA,
    hexFFA855F7,
    hexFFB8F2E6,
    hexFFCBD5E1,
    hexFFCCFBF1,
    hexFFD97706,
    hexFFDBEAFE,
    hexFFDCFCE7,
    hexFFDDEAF6,
    hexFFE0F2FE,
    hexFFE2E8F0,
    hexFFE5E7EB,
    hexFFEC4899,
    hexFFECFDF5,
    hexFFEEF2FF,
    hexFFEF4444,
    hexFFF1F5F9,
    hexFFF3E8FF,
    hexFFF3F4F6,
    hexFFF43F5E,
    hexFFF59E0B,
    hexFFF8FAFC,
    hexFFF97316,
    hexFFF9FAFB,
    hexFFFACC15,
    hexFFFB7185,
    hexFFFB923C,
    hexFFFCE7F3,
    hexFFFEF2F2,
    hexFFFEF3C7,
    hexFFFEF9C3,
    hexFFFFE4E6,
    hexFFFFE69A,
    hexFFFFEDD5,
    hexFFFFF1F2,
    hexFFFFFBEB,
    rgba_0_0_0_005,
    rgba_19_127_236_005,
    rgba_19_127_236_025,
    rgba_209_250_229_03,
    rgba_224_242_254_03,
    rgba_255_255_255_0,
    rgba_255_255_255_05,
    rgba_255_255_255_09,
  ];
}
