import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CategoryUtils {
  /// 카테고리 이름 가져오기 (l10n 연동)
  /// customName이 있으면 사용, 없으면 nameKey로 번역된 이름 반환
  static String getCategoryName(BuildContext context, Category category) {
    // 사용자 정의 이름이 있으면 사용
    if (category.customName != null && category.customName!.isNotEmpty) {
      return category.customName!;
    }

    // l10n 키로 번역된 이름 가져오기
    return getLocalizedName(context, category.nameKey);
  }

  /// 카테고리 nameKey를 현지화된 문자열로 변환
  static String getLocalizedName(BuildContext context, String nameKey) {
    final l10n = AppLocalizations.of(context);

    return switch (nameKey) {
      // 지출 카테고리
      'categoryFood' => l10n.categoryFood,
      'categoryTransport' => l10n.categoryTransport,
      'categoryShopping' => l10n.categoryShopping,
      'categoryHousing' => l10n.categoryHousing,
      'categoryMedical' => l10n.categoryMedical,
      'categoryEntertainment' => l10n.categoryEntertainment,
      'categoryEducation' => l10n.categoryEducation,
      'categoryOther' => l10n.categoryOther,

      // 수입 카테고리
      'categorySalary' => l10n.categorySalary,
      'categorySideIncome' => l10n.categorySideIncome,
      'categoryInterest' => l10n.categoryInterest,
      'categoryOtherIncome' => l10n.categoryOtherIncome,

      // 알 수 없는 키는 그대로 반환
      _ => nameKey,
    };
  }
}
