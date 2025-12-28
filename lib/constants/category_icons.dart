import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CategoryIcons {
  /// 카테고리별 아이콘 그룹
  static const Map<String, List<String>> iconsByCategory = {
    'food': [
      'fork-knife', 'coffee', 'beer-stein', 'wine', 'cake', 'cookie',
      'hamburger', 'pizza', 'bowl-food', 'egg', 'carrot', 'orange',
    ],
    'transport': [
      'car', 'bus', 'train', 'airplane', 'bicycle', 'taxi',
      'motorcycle', 'gas-pump', 'map-pin',
    ],
    'shopping': [
      'shopping-bag', 'shopping-cart', 't-shirt', 'sneaker', 'watch',
      'gift', 'tag', 'receipt', 'storefront', 'handbag',
    ],
    'living': [
      'house', 'lightbulb', 'drop', 'wrench', 'plug',
      'bed', 'bathtub', 'couch', 'plant',
    ],
    'health': [
      'first-aid', 'heartbeat', 'barbell', 'pill',
      'tooth', 'eye', 'brain',
    ],
    'leisure': [
      'game-controller', 'music-note', 'film-slate', 'camera', 'palette',
      'tennis-ball', 'soccer-ball', 'headphones', 'ticket',
    ],
    'education': [
      'graduation-cap', 'book-open', 'pencil', 'notebook', 'globe',
      'translate', 'certificate',
    ],
    'finance': [
      'briefcase', 'hand-coins', 'bank', 'chart-line', 'percent',
      'wallet', 'credit-card', 'piggy-bank', 'coins',
    ],
    'family': [
      'baby', 'paw-print', 'users', 'heart',
      'dog', 'cat', 'flower',
    ],
    'etc': [
      'star', 'flag', 'bookmark', 'lightning', 'cloud',
      'sun', 'moon', 'sparkle', 'dots-three',
    ],
  };

  /// 카테고리 순서
  static const List<String> categoryOrder = [
    'food', 'transport', 'shopping', 'living', 'health',
    'leisure', 'education', 'finance', 'family', 'etc',
  ];

  /// 모든 아이콘 (플랫 리스트)
  static List<String> get allIcons {
    return iconsByCategory.values.expand((list) => list).toList();
  }

  /// 기본 아이콘
  static String get defaultIcon => 'fork-knife';

  /// 하위 호환성: 기존 availableIcons 유지
  static List<String> get availableIcons => allIcons;

  /// 카테고리 이름 가져오기 (l10n 연동)
  static String getCategoryName(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context);
    return switch (category) {
      'food' => l10n.iconCategoryFood,
      'transport' => l10n.iconCategoryTransport,
      'shopping' => l10n.iconCategoryShopping,
      'living' => l10n.iconCategoryLiving,
      'health' => l10n.iconCategoryHealth,
      'leisure' => l10n.iconCategoryLeisure,
      'education' => l10n.iconCategoryEducation,
      'finance' => l10n.iconCategoryFinance,
      'family' => l10n.iconCategoryFamily,
      'etc' => l10n.iconCategoryEtc,
      _ => category,
    };
  }

  /// 아이콘 키 → IconData 변환
  static IconData getIcon(String iconName) {
    return _iconMap[iconName] ?? PhosphorIconsThin.question;
  }

  static const Map<String, IconData> _iconMap = {
    // Food
    'fork-knife': PhosphorIconsThin.forkKnife,
    'coffee': PhosphorIconsThin.coffee,
    'beer-stein': PhosphorIconsThin.beerStein,
    'wine': PhosphorIconsThin.wine,
    'cake': PhosphorIconsThin.cake,
    'cookie': PhosphorIconsThin.cookie,
    'hamburger': PhosphorIconsThin.hamburger,
    'pizza': PhosphorIconsThin.pizza,
    'bowl-food': PhosphorIconsThin.bowlFood,
    'egg': PhosphorIconsThin.egg,
    'carrot': PhosphorIconsThin.carrot,
    'orange': PhosphorIconsThin.orange,

    // Transport
    'car': PhosphorIconsThin.car,
    'bus': PhosphorIconsThin.bus,
    'train': PhosphorIconsThin.train,
    'airplane': PhosphorIconsThin.airplane,
    'bicycle': PhosphorIconsThin.bicycle,
    'taxi': PhosphorIconsThin.taxi,
    'motorcycle': PhosphorIconsThin.motorcycle,
    'gas-pump': PhosphorIconsThin.gasPump,
    'map-pin': PhosphorIconsThin.mapPin,

    // Shopping
    'shopping-bag': PhosphorIconsThin.shoppingBag,
    'shopping-cart': PhosphorIconsThin.shoppingCart,
    't-shirt': PhosphorIconsThin.tShirt,
    'sneaker': PhosphorIconsThin.sneaker,
    'watch': PhosphorIconsThin.watch,
    'gift': PhosphorIconsThin.gift,
    'tag': PhosphorIconsThin.tag,
    'receipt': PhosphorIconsThin.receipt,
    'storefront': PhosphorIconsThin.storefront,
    'handbag': PhosphorIconsThin.handbag,

    // Living
    'house': PhosphorIconsThin.house,
    'lightbulb': PhosphorIconsThin.lightbulb,
    'drop': PhosphorIconsThin.drop,
    'wrench': PhosphorIconsThin.wrench,
    'plug': PhosphorIconsThin.plug,
    'bed': PhosphorIconsThin.bed,
    'bathtub': PhosphorIconsThin.bathtub,
    'couch': PhosphorIconsThin.couch,
    'plant': PhosphorIconsThin.plant,

    // Health
    'first-aid': PhosphorIconsThin.firstAid,
    'heartbeat': PhosphorIconsThin.heartbeat,
    'barbell': PhosphorIconsThin.barbell,
    'pill': PhosphorIconsThin.pill,
    'tooth': PhosphorIconsThin.tooth,
    'eye': PhosphorIconsThin.eye,
    'brain': PhosphorIconsThin.brain,

    // Leisure
    'game-controller': PhosphorIconsThin.gameController,
    'music-note': PhosphorIconsThin.musicNote,
    'film-slate': PhosphorIconsThin.filmSlate,
    'camera': PhosphorIconsThin.camera,
    'palette': PhosphorIconsThin.palette,
    'tennis-ball': PhosphorIconsThin.tennisBall,
    'soccer-ball': PhosphorIconsThin.soccerBall,
    'headphones': PhosphorIconsThin.headphones,
    'ticket': PhosphorIconsThin.ticket,

    // Education
    'graduation-cap': PhosphorIconsThin.graduationCap,
    'book-open': PhosphorIconsThin.bookOpen,
    'pencil': PhosphorIconsThin.pencil,
    'notebook': PhosphorIconsThin.notebook,
    'globe': PhosphorIconsThin.globe,
    'translate': PhosphorIconsThin.translate,
    'certificate': PhosphorIconsThin.certificate,

    // Finance
    'briefcase': PhosphorIconsThin.briefcase,
    'hand-coins': PhosphorIconsThin.handCoins,
    'bank': PhosphorIconsThin.bank,
    'chart-line': PhosphorIconsThin.chartLine,
    'percent': PhosphorIconsThin.percent,
    'wallet': PhosphorIconsThin.wallet,
    'credit-card': PhosphorIconsThin.creditCard,
    'piggy-bank': PhosphorIconsThin.piggyBank,
    'coins': PhosphorIconsThin.coins,

    // Family
    'baby': PhosphorIconsThin.baby,
    'paw-print': PhosphorIconsThin.pawPrint,
    'users': PhosphorIconsThin.users,
    'heart': PhosphorIconsThin.heart,
    'dog': PhosphorIconsThin.dog,
    'cat': PhosphorIconsThin.cat,
    'flower': PhosphorIconsThin.flower,

    // Etc
    'star': PhosphorIconsThin.star,
    'flag': PhosphorIconsThin.flag,
    'bookmark': PhosphorIconsThin.bookmark,
    'lightning': PhosphorIconsThin.lightning,
    'cloud': PhosphorIconsThin.cloud,
    'sun': PhosphorIconsThin.sun,
    'moon': PhosphorIconsThin.moon,
    'sparkle': PhosphorIconsThin.sparkle,
    'dots-three': PhosphorIconsThin.dotsThree,
  };
}
