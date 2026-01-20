import 'package:flutter/foundation.dart';

/// 거래 변경 이벤트를 알리는 전역 Notifier
class TransactionNotifier extends ChangeNotifier {
  static final TransactionNotifier _instance = TransactionNotifier._internal();
  factory TransactionNotifier() => _instance;
  TransactionNotifier._internal();

  /// 거래가 변경되었음을 알림 (추가/수정/삭제)
  void notifyTransactionChanged() {
    notifyListeners();
  }
}
