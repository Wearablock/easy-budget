import 'package:easy_budget/app.dart';
import 'package:easy_budget/constants/app_colors.dart';
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DismissibleTransactionTile extends StatelessWidget {
  final Transaction transaction;
  final AppDatabase database;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  const DismissibleTransactionTile({
    super.key,
    required this.transaction,
    required this.database,
    this.onTap,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('transaction_${transaction.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmAndDelete(context),
      dismissThresholds: const {DismissDirection.endToStart: 0.25},
      background: _buildDeleteBackground(context),
      child: TransactionTile(
        transaction: transaction,
        database: database,
        onTap: onTap,
      ),
    );
  }

  Widget _buildDeleteBackground(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.expense,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(PhosphorIconsThin.trash, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            l10n.delete,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 삭제 확인 후 삭제 처리 및 스낵바 표시
  /// confirmDismiss에서 모든 작업을 처리하여 context 유효성 문제 방지
  Future<bool> _confirmAndDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    // 앱 전역 ScaffoldMessenger 사용 (위젯 트리 변경 시에도 스낵바 정상 작동)
    final messenger = EasyBudgetApp.scaffoldMessengerKey.currentState;
    final transactionId = transaction.id;

    // 햅틱 피드백
    HapticFeedback.mediumImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      await database.softDeleteTransaction(transactionId);

      // 햅틱 피드백
      HapticFeedback.mediumImpact();

      // 성공 SnackBar with Undo
      messenger?.clearSnackBars();

      // SnackBarAction과 duration이 함께 작동하지 않는 문제 해결:
      // 수동으로 타이머를 관리하여 스낵바 닫기
      final snackBarController = messenger?.showSnackBar(
        SnackBar(
          content: Text(l10n.transactionDeleted),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => database.restoreTransaction(transactionId),
          ),
          // duration을 길게 설정 (수동 타이머로 관리)
          duration: const Duration(days: 1),
        ),
      );

      // 3초 후 수동으로 스낵바 닫기
      Future.delayed(const Duration(seconds: 3), () {
        snackBarController?.close();
      });

      onDeleted?.call();
      return true;
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(l10n.errorOccurred),
          backgroundColor: AppColors.expense,
        ),
      );
      return false;
    }
  }
}
