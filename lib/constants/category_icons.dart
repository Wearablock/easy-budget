import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CategoryIcons {
  static IconData getIcon(String iconName) {
    switch (iconName) {
      // 지출 카테고리
      case 'fork-knife':
        return PhosphorIconsThin.forkKnife;
      case 'car':
        return PhosphorIconsThin.car;
      case 'shopping-bag':
        return PhosphorIconsThin.shoppingBag;
      case 'house':
        return PhosphorIconsThin.house;
      case 'first-aid':
        return PhosphorIconsThin.firstAid;
      case 'game-controller':
        return PhosphorIconsThin.gameController;
      case 'book-open':
        return PhosphorIconsThin.bookOpen;
      case 'dots-three':
        return PhosphorIconsThin.dotsThree;

      // 수입 카테고리
      case 'briefcase':
        return PhosphorIconsThin.briefcase;
      case 'hand-coins':
        return PhosphorIconsThin.handCoins;
      case 'percent':
        return PhosphorIconsThin.percent;

      default:
        return PhosphorIconsThin.question;
    }
  }
}
