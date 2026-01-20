/// 날짜 계산 유틸리티
class DateHelper {
  DateHelper._();

  /// 해당 월의 시작 시간 (00:00:00)
  static DateTime getMonthStart(int year, int month) {
    return DateTime(year, month, 1);
  }

  /// 해당 월의 마지막 시간 (23:59:59)
  static DateTime getMonthEnd(int year, int month) {
    return DateTime(year, month + 1, 0, 23, 59, 59);
  }

  /// 해당 월의 마지막 날짜 (day만)
  static int getLastDayOfMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// 이전 달 계산
  static ({int year, int month}) getPreviousMonth(int year, int month) {
    if (month == 1) {
      return (year: year - 1, month: 12);
    }
    return (year: year, month: month - 1);
  }

  /// 다음 달 계산
  static ({int year, int month}) getNextMonth(int year, int month) {
    if (month == 12) {
      return (year: year + 1, month: 1);
    }
    return (year: year, month: month + 1);
  }
}
