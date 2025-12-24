import 'package:flutter/material.dart';

class AppColors {
  // ===== Primary (메인 그린) =====
  static const Color primary = Color(0xFF59C36A);
  static const Color primaryLight = Color(0xFF7DD68B);
  static const Color primaryDark = Color(0xFF3DAA57);
  static const Color primaryDarker = Color(0xFF2E8B47);

  // ===== 수입/지출 =====
  static const Color income = Color(0xFF59C36A);      // 그린 (수입)
  static const Color expense = Color(0xFFF44336);     // 레드 (지출)
  static const Color incomeLight = Color(0xFFE8F5E9);  // 수입 배경
  static const Color expenseLight = Color(0xFFFFEBEE); // 지출 배경

  // ===== 배경 (라이트 모드) =====
  static const Color backgroundLight = Color(0xFFFFF9E6);  // 연한 크림
  static const Color surfaceLight = Color(0xFFFFFFFF);     // 카드 배경
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);

  // ===== 배경 (다크 모드) =====
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  // ===== 텍스트 (라이트 모드) =====
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textTertiaryLight = Color(0xFF9E9E9E);

  // ===== 텍스트 (다크 모드) =====
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textTertiaryDark = Color(0xFF808080);

  // ===== 기타 =====
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA726);
  static const Color success = Color(0xFF66BB6A);
}
