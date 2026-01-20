import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/models/monthly_trend_data.dart';
import 'package:easy_budget/models/statistics_data.dart';

/// 통계 관련 비즈니스 로직을 처리하는 서비스
class StatisticsService {
  final AppDatabase _database;

  StatisticsService(this._database);

  /// 특정 월의 통계 데이터 조회
  Future<StatisticsData> getMonthlyStatistics(int year, int month) async {
    final income = await _database.getTotalIncomeByMonth(year, month);
    final expense = await _database.getTotalExpenseByMonth(year, month);

    int? previousBalance;
    try {
      previousBalance = await _database.getBalanceBeforeMonth(year, month);
    } catch (_) {
      // 전월 데이터 없음
    }

    final expensesByCategory = await _database.getExpensesByCategory(
      year,
      month,
    );
    final incomesByCategory = await _database.getIncomesByCategory(
      year,
      month,
    );

    return StatisticsData(
      income: income,
      expense: expense,
      previousBalance: previousBalance,
      expensesByCategory: expensesByCategory,
      incomesByCategory: incomesByCategory,
    );
  }

  /// 월별 수입 합계
  Future<int> getTotalIncomeByMonth(int year, int month) {
    return _database.getTotalIncomeByMonth(year, month);
  }

  /// 월별 지출 합계
  Future<int> getTotalExpenseByMonth(int year, int month) {
    return _database.getTotalExpenseByMonth(year, month);
  }

  /// 전월 이월 잔액
  Future<int> getBalanceBeforeMonth(int year, int month) {
    return _database.getBalanceBeforeMonth(year, month);
  }

  /// 카테고리별 지출 조회
  Future<List<CategoryExpenseData>> getExpensesByCategory(int year, int month) {
    return _database.getExpensesByCategory(year, month);
  }

  /// 카테고리별 수입 조회
  Future<List<CategoryExpenseData>> getIncomesByCategory(int year, int month) {
    return _database.getIncomesByCategory(year, month);
  }

  /// 월별 추이 데이터 (바 차트용)
  Future<List<MonthlyTrendData>> getMonthlyTrends({
    required int endYear,
    required int endMonth,
    int monthCount = 6,
  }) {
    return _database.getMonthlyTrends(
      endYear: endYear,
      endMonth: endMonth,
      monthCount: monthCount,
    );
  }

  /// 누적 잔액 추이 (라인 차트용)
  Future<List<MonthlyTrendData>> getCumulativeBalances({
    required int endYear,
    required int endMonth,
    int monthCount = 6,
  }) {
    return _database.getCumulativeBalances(
      endYear: endYear,
      endMonth: endMonth,
      monthCount: monthCount,
    );
  }
}
