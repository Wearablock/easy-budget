import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:easy_budget/database/category_seeder.dart';
import 'package:easy_budget/models/monthly_trend_data.dart';
import 'package:easy_budget/utils/date_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nameKey => text()();
  TextColumn get customName => text().nullable()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  BoolColumn get isIncome => boolean()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amount => integer()();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  BoolColumn get isIncome => boolean()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await CategorySeeder.seedDefaultCategories(this);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 3) {
          // 기타 카테고리의 sortOrder를 9999로 업데이트
          await customStatement('''
            UPDATE categories
            SET sort_order = 9999
            WHERE name_key IN ('categoryOther', 'categoryOtherIncome')
          ''');
        }
        if (from < 2) {
          await m.addColumn(transactions, transactions.currencyCode);

          await customStatement('''
            CREATE TABLE transactions_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              amount INTEGER NOT NULL,
              currency_code TEXT NOT NULL DEFAULT 'USD',
              is_income INTEGER NOT NULL,
              category_id INTEGER NOT NULL REFERENCES categories(id),
              memo TEXT,
              transaction_date INTEGER NOT NULL,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
              is_deleted INTEGER NOT NULL DEFAULT 0
            )
          ''');

          await customStatement('''
            INSERT INTO transactions_new 
            SELECT id, CAST(amount AS INTEGER), 'USD', is_income, category_id, 
                  memo, transaction_date, created_at, is_deleted
            FROM transactions
          ''');

          await customStatement('DROP TABLE transactions');
          await customStatement(
            'ALTER TABLE transactions_new RENAME TO transactions',
          );
        }
      },
    );
  }

  // ===== Categories CRUD =====

  Future<List<Category>> getAllCategories() {
    return (select(categories)
          ..where((c) => c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  Future<List<Category>> getExpenseCategories() {
    return (select(categories)
          ..where((c) => c.isDeleted.equals(false) & c.isIncome.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  Future<List<Category>> getIncomeCategories() {
    return (select(categories)
          ..where((c) => c.isDeleted.equals(false) & c.isIncome.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  Future<Category?> getCategoryById(int id) {
    return (select(
      categories,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Category>> watchExpenseCategories() {
    return (select(categories)
          ..where((c) => c.isDeleted.equals(false) & c.isIncome.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  Stream<List<Category>> watchIncomeCategories() {
    return (select(categories)
          ..where((c) => c.isDeleted.equals(false) & c.isIncome.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  Future<bool> updateCategory(Category category) {
    return update(categories).replace(category);
  }

  Future<int> softDeleteCategory(int id) {
    return (update(categories)..where((c) => c.id.equals(id))).write(
      const CategoriesCompanion(isDeleted: Value(true)),
    );
  }

  /// 카테고리 이름 중복 체크
  ///
  /// 같은 타입(수입/지출)에서 동일한 이름이 있는지 확인
  Future<bool> isCategoryNameExists(String name, bool isIncome) async {
    final categories = isIncome
        ? await getIncomeCategories()
        : await getExpenseCategories();

    return categories.any(
      (c) => c.customName?.toLowerCase() == name.toLowerCase(),
    );
  }

  /// 새 카테고리의 sortOrder 계산
  ///
  /// 기타 카테고리(sortOrder=9999) 앞에 오도록 최대값 + 1 반환
  Future<int> getNextCategorySortOrder(bool isIncome) async {
    final categoryList = isIncome
        ? await getIncomeCategories()
        : await getExpenseCategories();

    // 기타 카테고리(9999) 제외한 최대 sortOrder 찾기
    int maxOrder = 0;
    for (final category in categoryList) {
      if (category.sortOrder < 9999 && category.sortOrder > maxOrder) {
        maxOrder = category.sortOrder;
      }
    }

    return maxOrder + 1;
  }

  /// 카테고리 ID로 거래 수 조회
  Future<int> getTransactionCountByCategory(int categoryId) async {
    final result = await (selectOnly(transactions)
          ..addColumns([transactions.id.count()])
          ..where(
            transactions.isDeleted.equals(false) &
                transactions.categoryId.equals(categoryId),
          ))
        .getSingleOrNull();

    return result?.read(transactions.id.count()) ?? 0;
  }

  /// 카테고리 삭제 시 거래를 "기타" 카테고리로 이동
  Future<void> moveCategoryTransactionsToOther(
    int fromCategoryId,
    bool isIncome,
  ) async {
    // 기타 카테고리 찾기
    final otherCategory = await (select(categories)
          ..where(
            (c) =>
                c.isDeleted.equals(false) &
                c.isIncome.equals(isIncome) &
                c.nameKey.equals(
                  isIncome ? 'categoryOtherIncome' : 'categoryOther',
                ),
          ))
        .getSingleOrNull();

    if (otherCategory != null) {
      await (update(transactions)
            ..where((t) => t.categoryId.equals(fromCategoryId)))
          .write(TransactionsCompanion(categoryId: Value(otherCategory.id)));
    }
  }

  /// 카테고리 이름 중복 체크 (자신 제외)
  ///
  /// 수정 시 자기 자신은 제외하고 중복 체크
  Future<bool> isCategoryNameExistsExcept(
    String name,
    bool isIncome,
    int excludeId,
  ) async {
    final categoryList = isIncome
        ? await getIncomeCategories()
        : await getExpenseCategories();

    return categoryList.any(
      (c) =>
          c.id != excludeId &&
          c.customName?.toLowerCase() == name.toLowerCase(),
    );
  }

  // ===== Transactions CRUD =====

  Future<List<Transaction>> getAllTransactions() {
    return (select(transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  Future<List<Transaction>> getTransactionsByMonth(int year, int month) {
    final startDate = DateHelper.getMonthStart(year, month);
    final endDate = DateHelper.getMonthEnd(year, month);

    return (select(transactions)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                t.transactionDate.isBiggerOrEqualValue(startDate) &
                t.transactionDate.isSmallerOrEqualValue(endDate),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  Future<List<Transaction>> getTransactionsByCategory(int categoryId) {
    return (select(transactions)
          ..where(
            (t) => t.isDeleted.equals(false) & t.categoryId.equals(categoryId),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  Future<Transaction?> getTransactionById(int id) {
    return (select(
      transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Transaction>> watchTransactionsByMonth(int year, int month) {
    final startDate = DateHelper.getMonthStart(year, month);
    final endDate = DateHelper.getMonthEnd(year, month);

    return (select(transactions)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                t.transactionDate.isBiggerOrEqualValue(startDate) &
                t.transactionDate.isSmallerOrEqualValue(endDate),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  Future<int> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  Future<bool> updateTransaction(Transaction transaction) {
    return update(transactions).replace(transaction);
  }

  Future<int> softDeleteTransaction(int id) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      const TransactionsCompanion(isDeleted: Value(true)),
    );
  }

  Future<int> restoreTransaction(int id) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      const TransactionsCompanion(isDeleted: Value(false)),
    );
  }

  // ===== 통계 메서드 =====

  Future<int> getTotalIncomeByMonth(int year, int month) async {
    final startDate = DateHelper.getMonthStart(year, month);
    final endDate = DateHelper.getMonthEnd(year, month);

    final result =
        await (selectOnly(transactions)
              ..addColumns([transactions.amount.sum()])
              ..where(
                transactions.isDeleted.equals(false) &
                    transactions.isIncome.equals(true) &
                    transactions.transactionDate.isBiggerOrEqualValue(
                      startDate,
                    ) &
                    transactions.transactionDate.isSmallerOrEqualValue(endDate),
              ))
            .getSingleOrNull();

    return result?.read(transactions.amount.sum()) ?? 0;
  }

  Future<int> getTotalExpenseByMonth(int year, int month) async {
    final startDate = DateHelper.getMonthStart(year, month);
    final endDate = DateHelper.getMonthEnd(year, month);

    final result =
        await (selectOnly(transactions)
              ..addColumns([transactions.amount.sum()])
              ..where(
                transactions.isDeleted.equals(false) &
                    transactions.isIncome.equals(false) &
                    transactions.transactionDate.isBiggerOrEqualValue(
                      startDate,
                    ) &
                    transactions.transactionDate.isSmallerOrEqualValue(endDate),
              ))
            .getSingleOrNull();

    return result?.read(transactions.amount.sum()) ?? 0;
  }

  /// 특정 월의 카테고리별 지출 합계 조회
  Future<List<CategoryExpenseData>> getExpensesByCategory(
    int year,
    int month,
  ) async {
    return _getTransactionsByCategory(year, month, isIncome: false);
  }

  /// 특정 월 이전의 누적 잔액 조회 (전월까지의 잔액)
  Future<int> getBalanceBeforeMonth(int year, int month) async {
    final endDate = DateTime(year, month, 1).subtract(
      const Duration(seconds: 1),
    );

    final incomeResult =
        await (selectOnly(transactions)
              ..addColumns([transactions.amount.sum()])
              ..where(
                transactions.isDeleted.equals(false) &
                    transactions.isIncome.equals(true) &
                    transactions.transactionDate.isSmallerOrEqualValue(endDate),
              ))
            .getSingleOrNull();

    final expenseResult =
        await (selectOnly(transactions)
              ..addColumns([transactions.amount.sum()])
              ..where(
                transactions.isDeleted.equals(false) &
                    transactions.isIncome.equals(false) &
                    transactions.transactionDate.isSmallerOrEqualValue(endDate),
              ))
            .getSingleOrNull();

    final income = incomeResult?.read(transactions.amount.sum()) ?? 0;
    final expense = expenseResult?.read(transactions.amount.sum()) ?? 0;

    return income - expense;
  }

  /// 특정 월의 카테고리별 수입 합계 조회
  Future<List<CategoryExpenseData>> getIncomesByCategory(
    int year,
    int month,
  ) async {
    return _getTransactionsByCategory(year, month, isIncome: true);
  }

  /// 카테고리별 거래 합계 조회 (공통 로직)
  Future<List<CategoryExpenseData>> _getTransactionsByCategory(
    int year,
    int month, {
    required bool isIncome,
  }) async {
    final startDate = DateHelper.getMonthStart(year, month);
    final endDate = DateHelper.getMonthEnd(year, month);

    final query = select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..where(
        transactions.isDeleted.equals(false) &
            transactions.isIncome.equals(isIncome) &
            transactions.transactionDate.isBiggerOrEqualValue(startDate) &
            transactions.transactionDate.isSmallerOrEqualValue(endDate),
      );

    final results = await query.get();

    // 카테고리별로 그룹화하여 합계 계산
    final Map<int, CategoryExpenseData> categoryMap = {};

    for (final row in results) {
      final category = row.readTable(categories);
      final transaction = row.readTable(transactions);

      if (categoryMap.containsKey(category.id)) {
        final existing = categoryMap[category.id]!;
        categoryMap[category.id] = CategoryExpenseData(
          categoryId: category.id,
          categoryName: category.customName ?? category.nameKey,
          iconName: category.icon,
          colorValue: category.color,
          amount: existing.amount + transaction.amount,
          percentage: 0,
        );
      } else {
        categoryMap[category.id] = CategoryExpenseData(
          categoryId: category.id,
          categoryName: category.customName ?? category.nameKey,
          iconName: category.icon,
          colorValue: category.color,
          amount: transaction.amount,
          percentage: 0,
        );
      }
    }

    // 총 금액 계산
    final totalAmount = categoryMap.values.fold<int>(
      0,
      (sum, data) => sum + data.amount,
    );

    // 퍼센트 계산 및 정렬
    final resultList = categoryMap.values.map((data) {
      return CategoryExpenseData(
        categoryId: data.categoryId,
        categoryName: data.categoryName,
        iconName: data.iconName,
        colorValue: data.colorValue,
        amount: data.amount,
        percentage: totalAmount > 0 ? (data.amount / totalAmount) * 100 : 0,
      );
    }).toList();

    // 금액 높은 순으로 정렬
    resultList.sort((a, b) => b.amount.compareTo(a.amount));

    return resultList;
  }

  // ===== 월별 추이 메서드 =====

  /// 최근 N개월간 월별 수입/지출 합계 조회
  ///
  /// [endYear], [endMonth]: 기준 월 (포함)
  /// [monthCount]: 조회할 개월 수 (기본 6개월)
  ///
  /// 반환: 과거 → 현재 순으로 정렬된 월별 데이터
  Future<List<MonthlyTrendData>> getMonthlyTrends({
    required int endYear,
    required int endMonth,
    int monthCount = 6,
  }) async {
    final results = <MonthlyTrendData>[];

    // 시작 월 계산 (monthCount개월 전으로 이동)
    var year = endYear;
    var month = endMonth;

    for (var i = 0; i < monthCount - 1; i++) {
      final prev = DateHelper.getPreviousMonth(year, month);
      year = prev.year;
      month = prev.month;
    }

    // 각 월별 데이터 조회
    for (var i = 0; i < monthCount; i++) {
      final income = await getTotalIncomeByMonth(year, month);
      final expense = await getTotalExpenseByMonth(year, month);

      results.add(MonthlyTrendData(
        year: year,
        month: month,
        income: income,
        expense: expense,
      ));

      // 다음 월로 이동
      final next = DateHelper.getNextMonth(year, month);
      year = next.year;
      month = next.month;
    }

    return results;
  }

  /// 최근 N개월간 누적 잔액 조회 (라인 차트용)
  ///
  /// 각 월말 기준 누적 잔액을 반환
  Future<List<MonthlyTrendData>> getCumulativeBalances({
    required int endYear,
    required int endMonth,
    int monthCount = 6,
  }) async {
    final results = <MonthlyTrendData>[];

    // 시작 월 계산 (monthCount개월 전으로 이동)
    var year = endYear;
    var month = endMonth;

    for (var i = 0; i < monthCount - 1; i++) {
      final prev = DateHelper.getPreviousMonth(year, month);
      year = prev.year;
      month = prev.month;
    }

    // 시작 월 이전까지의 누적 잔액
    int cumulativeBalance = await getBalanceBeforeMonth(year, month);

    // 각 월별 데이터 조회
    for (var i = 0; i < monthCount; i++) {
      final income = await getTotalIncomeByMonth(year, month);
      final expense = await getTotalExpenseByMonth(year, month);

      // 해당 월까지의 누적 잔액
      cumulativeBalance += (income - expense);

      results.add(MonthlyTrendData(
        year: year,
        month: month,
        income: income,
        expense: expense,
        cumulativeBalance: cumulativeBalance,
      ));

      // 다음 월로 이동
      final next = DateHelper.getNextMonth(year, month);
      year = next.year;
      month = next.month;
    }

    return results;
  }
}

/// 카테고리별 지출 데이터 클래스
class CategoryExpenseData {
  final int categoryId;
  final String categoryName;
  final String iconName;
  final int colorValue;
  final int amount;
  final double percentage;

  CategoryExpenseData({
    required this.categoryId,
    required this.categoryName,
    required this.iconName,
    required this.colorValue,
    required this.amount,
    required this.percentage,
  });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'easy_budget.db'));
    return NativeDatabase.createInBackground(file);
  });
}
