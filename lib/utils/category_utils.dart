import 'package:flutter/material.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/database/database.dart';

class CategoryUtils {
  /// 카테고리 이름 가져오기 (l10n 연동)
  static String getCategoryName(BuildContext context, Category category) {
    final l10n = AppLocalizations.of(context);

    // 사용자 정의 이름이 있으면 사용
    if (category.customName != null && category.customName!.isNotEmpty) {
      return category.customName!;
    }

    // l10n 키로 번역된 이름 가져오기
    switch (category.nameKey) {
      case 'categoryFood':
        return l10n.categoryFood;
      case 'categoryTransport':
        return l10n.categoryTransport;
      case 'categoryShopping':
        return l10n.categoryShopping;
      case 'categoryHousing':
        return l10n.categoryHousing;
      case 'categoryMedical':
        return l10n.categoryMedical;
      case 'categoryEntertainment':
        return l10n.categoryEntertainment;
      case 'categoryEducation':
        return l10n.categoryEducation;
      case 'categoryOther':
        return l10n.categoryOther;
      case 'categorySalary':
        return l10n.categorySalary;
      case 'categorySideIncome':
        return l10n.categorySideIncome;
      case 'categoryInterest':
        return l10n.categoryInterest;
      case 'categoryOtherIncome':
        return l10n.categoryOtherIncome;
      default:
        return category.nameKey;
    }
  }

  /// 카테고리 nameKey를 현지화된 문자열로 변환
  static String getLocalizedName(BuildContext context, String nameKey) {
    final l10n = AppLocalizations.of(context);

    // nameKey에 따라 적절한 번역 반환
    switch (nameKey) {
      // 지출 카테고리
      case 'categoryFood':
        return l10n.categoryFood;
      case 'categoryTransport':
        return l10n.categoryTransport;
      case 'categoryShopping':
        return l10n.categoryShopping;
      case 'categoryHousing':
        return l10n.categoryHousing;
      case 'categoryMedical':
        return l10n.categoryMedical;
      case 'categoryEntertainment':
        return l10n.categoryEntertainment;
      case 'categoryEducation':
        return l10n.categoryEducation;
      case 'categoryOther':
        return l10n.categoryOther;

      // 수입 카테고리
      case 'categorySalary':
        return l10n.categorySalary;
      case 'categorySideIncome':
        return l10n.categorySideIncome;
      case 'categoryInterest':
        return l10n.categoryInterest;
      case 'categoryOtherIncome':
        return l10n.categoryOtherIncome;

      default:
        return nameKey;
    }
  }
}
