/// 앱 전역에서 사용하는 제한값 상수
///
/// 입력 길이 제한, 금액 제한 등을 정의합니다.
class AppLimits {
  AppLimits._();

  // ===== 금액 관련 =====

  /// 화면에 표시할 수 있는 최대 금액 (정수부)
  static const int maxDisplayAmount = 999999999;

  // ===== 텍스트 길이 제한 =====

  /// 메모 최대 길이
  static const int maxMemoLength = 100;

  /// 카테고리 이름 최대 길이
  static const int maxCategoryNameLength = 20;

  // ===== 날짜 관련 =====

  /// 거래 기록 시작 가능 연도
  static const int transactionStartYear = 2020;

  // ===== 통계 관련 =====

  /// 월별 추이 차트에서 보여줄 최근 개월 수
  static const int trendMonthsCount = 6;
}
