import 'package:flutter/material.dart';

/// 앱 전역에서 사용하는 간격 및 크기 상수
///
/// 패딩, 마진, 간격, BorderRadius 등을 정의합니다.
class AppSpacing {
  AppSpacing._();

  // ===== 기본 간격 =====

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // ===== BorderRadius =====

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 24.0; // 완전 라운드 버튼용

  // ===== 아이콘 컨테이너 크기 =====

  static const double iconContainerSm = 40.0;
  static const double iconContainerMd = 48.0;
  static const double iconContainerLg = 56.0;

  // ===== 자주 사용하는 BorderRadius =====

  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);

  // ===== 자주 사용하는 EdgeInsets =====

  /// 전체 패딩 (16)
  static const EdgeInsets paddingAll = EdgeInsets.all(lg);

  /// 전체 패딩 (8)
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);

  /// 전체 패딩 (24)
  static const EdgeInsets paddingAllLg = EdgeInsets.all(xxl);

  /// 수평 패딩 (16)
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: lg);

  /// 수평 패딩 (24)
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: xxl);

  /// 수직 패딩 (16)
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: lg);

  /// 입력 필드 내부 패딩
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: 14.0,
  );

  // ===== 자주 사용하는 SizedBox =====

  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);

  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalLg = SizedBox(width: lg);
}
