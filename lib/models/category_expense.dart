import 'dart:ui';

class CategoryExpense {
  final int categoryId;
  final String categoryName;
  final String iconName;
  final int colorValue;
  final int amount;
  final double percentage; // 전체 지출 대비 비율

  CategoryExpense({
    required this.categoryId,
    required this.categoryName,
    required this.iconName,
    required this.colorValue,
    required this.amount,
    required this.percentage,
  });

  Color get color => Color(colorValue);
}
