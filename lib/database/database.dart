import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultCategories();
      },
      onUpgrade: (Migrator m, int from, int to) async {
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

  // ===== Transactions CRUD =====

  Future<List<Transaction>> getAllTransactions() {
    return (select(transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  Future<List<Transaction>> getTransactionsByMonth(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

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
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

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

  // ===== 통계 메서드 =====

  Future<int> getTotalIncomeByMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

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
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

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

  // ===== Private Methods =====

  Future<void> _seedDefaultCategories() async {
    // 지출 카테고리
    final expenseCategories = [
      CategoriesCompanion.insert(
        nameKey: 'categoryFood',
        icon: 'fork-knife',
        color: 0xFFFF9800,
        isIncome: false,
        isDefault: const Value(true),
        sortOrder: const Value(0),
      ),
      CategoriesCompanion.insert(
        nameKey: 'categoryTransport',
        icon: 'car',
        color: 0xFF2196F3,
        isIncome: false,
        isDefault: const Value(true),
        sortOrder: const Value(1),
      ),
      CategoriesCompanion.insert(
        nameKey: 'categoryShopping',
        icon: 'shopping-bag',
        color: 0xFFE91E63,
        isIncome: false,
        isDefault: const Value(true),
        sortOrder: const Value(2),
      ),
      CategoriesCompanion.insert(
        nameKey: 'categoryHousing',
        icon: 'house',
        color: 0xFF795548,
        isIncome: false,
        isDefault: const Value(true),
        sortOrder: const Value(3),
      ),
      CategoriesCompanion.insert(
        nameKey: 'categoryMedical',
        icon: 'first-aid',
        color: 0xFFF44336,
        isIncome: false,
        isDefault: const Value(true),
        sortOrder: const Value(4),
      ),
      CategoriesCompanion.insert(
        nameKey: 'categoryEntertainment',
        icon: 'game-controller',
        color: 0xFF9C27B0,
        isIncome: false,
        isDefault: const Value(true),
        sortOrder: const Value(5),
      ),
      CategoriesCompanion.insert(
        nameKey: 'categoryEducation',
        icon: 'book-open',
        color: 0xFF3F51B5,
        isIncome: false,
        isDefault: const Value(true),
        sortOrder: const Value(6),
      ),
      CategoriesCompanion.insert(
        nameKey: 'categoryOther',
        icon: 'dots-three',
        color: 0xFF607D8B,
        isIncome: false,
        isDefault: const Value(true),
        sortOrder: const Value(7),
      ),
    ];

    // 수입 카테고리
    final incomeCategories = [
      CategoriesCompanion.insert(
        nameKey: 'categorySalary',
        icon: 'briefcase',
        color: 0xFF4CAF50,
        isIncome: true,
        isDefault: const Value(true),
        sortOrder: const Value(0),
      ),
      CategoriesCompanion.insert(
        nameKey: 'categorySideIncome',
        icon: 'hand-coins',
        color: 0xFF8BC34A,
        isIncome: true,
        isDefault: const Value(true),
        sortOrder: const Value(1),
      ),
      CategoriesCompanion.insert(
        nameKey: 'categoryInterest',
        icon: 'percent',
        color: 0xFF00BCD4,
        isIncome: true,
        isDefault: const Value(true),
        sortOrder: const Value(2),
      ),
      CategoriesCompanion.insert(
        nameKey: 'categoryOtherIncome',
        icon: 'dots-three',
        color: 0xFF607D8B,
        isIncome: true,
        isDefault: const Value(true),
        sortOrder: const Value(3),
      ),
    ];

    // 모든 카테고리 삽입
    await batch((batch) {
      batch.insertAll(categories, expenseCategories);
      batch.insertAll(categories, incomeCategories);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'easy_budget.db'));
    return NativeDatabase.createInBackground(file);
  });
}
