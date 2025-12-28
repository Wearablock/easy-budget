import 'package:flutter/material.dart';

class CategoryColors {
  /// 카테고리 색상 프리셋
  static const List<Color> presets = [
    Color(0xFFF44336), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFFFFC107), // Amber
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFF9C27B0), // Purple
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFE91E63), // Pink
    Color(0xFF00BCD4), // Cyan
    Color(0xFF8BC34A), // Light Green
    Color(0xFF3F51B5), // Indigo
  ];

  /// 기본 색상 (첫 번째 프리셋)
  static Color get defaultColor => presets.first;
}
