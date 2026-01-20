import 'package:drift/drift.dart';
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/services/transaction_notifier.dart';
import 'package:easy_budget/utils/currency_utils.dart';

/// 거래 관련 비즈니스 로직을 처리하는 서비스
class TransactionService {
  final AppDatabase _database;

  TransactionService(this._database);

  /// 새 거래 추가
  Future<int> addTransaction({
    required int amount,
    required bool isIncome,
    required int categoryId,
    required DateTime transactionDate,
    String? memo,
  }) async {
    final transaction = TransactionsCompanion.insert(
      amount: amount,
      currencyCode: Value(CurrencyUtils.currentCurrency.code),
      isIncome: isIncome,
      categoryId: categoryId,
      memo: Value(memo),
      transactionDate: transactionDate,
    );

    final id = await _database.insertTransaction(transaction);
    TransactionNotifier().notifyTransactionChanged();
    return id;
  }

  /// 기존 거래 수정
  Future<void> updateTransaction({
    required Transaction existingTransaction,
    required int amount,
    required bool isIncome,
    required int categoryId,
    required DateTime transactionDate,
    String? memo,
  }) async {
    final updated = existingTransaction.copyWith(
      amount: amount,
      isIncome: isIncome,
      categoryId: categoryId,
      memo: Value(memo),
      transactionDate: transactionDate,
    );

    await _database.updateTransaction(updated);
    TransactionNotifier().notifyTransactionChanged();
  }

  /// 거래 삭제 (soft delete)
  Future<void> deleteTransaction(int id) async {
    await _database.softDeleteTransaction(id);
    TransactionNotifier().notifyTransactionChanged();
  }

  /// 거래 복원
  Future<void> restoreTransaction(int id) async {
    await _database.restoreTransaction(id);
    TransactionNotifier().notifyTransactionChanged();
  }

  /// 월별 거래 목록 조회
  Future<List<Transaction>> getTransactionsByMonth(int year, int month) {
    return _database.getTransactionsByMonth(year, month);
  }

  /// 월별 거래 목록 스트림 (실시간 업데이트)
  Stream<List<Transaction>> watchTransactionsByMonth(int year, int month) {
    return _database.watchTransactionsByMonth(year, month);
  }

  /// 카테고리별 거래 목록 조회
  Future<List<Transaction>> getTransactionsByCategory(int categoryId) {
    return _database.getTransactionsByCategory(categoryId);
  }

  /// 거래 ID로 조회
  Future<Transaction?> getTransactionById(int id) {
    return _database.getTransactionById(id);
  }
}
