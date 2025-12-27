import 'package:drift/drift.dart';
import 'package:easy_budget/database/database.dart';

/// 기본 카테고리 시딩을 담당하는 클래스
class CategorySeeder {
  /// 기본 카테고리 데이터를 시드합니다
  static Future<void> seedDefaultCategories(AppDatabase db) async {
    final expenseCategories = _createExpenseCategories();
    final incomeCategories = _createIncomeCategories();

    await db.batch((batch) {
      batch.insertAll(db.categories, expenseCategories);
      batch.insertAll(db.categories, incomeCategories);
    });
  }

  /// 지출 카테고리 목록 생성
  static List<CategoriesCompanion> _createExpenseCategories() {
    return [
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
  }

  /// 수입 카테고리 목록 생성
  static List<CategoriesCompanion> _createIncomeCategories() {
    return [
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
  }
}
