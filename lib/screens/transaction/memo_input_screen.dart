import 'package:drift/drift.dart' show Value;
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MemoInputScreen extends StatefulWidget {
  final AppDatabase database;
  final bool isIncome;
  final int amountInMinorUnits;
  final int categoryId;
  final DateTime transactionDate;

  const MemoInputScreen({
    super.key,
    required this.database,
    required this.isIncome,
    required this.amountInMinorUnits,
    required this.categoryId,
    required this.transactionDate,
  });

  @override
  State<MemoInputScreen> createState() => _MemoInputScreenState();
}

class _MemoInputScreenState extends State<MemoInputScreen> {
  final TextEditingController _memoController = TextEditingController();
  final FocusNode _memoFocusNode = FocusNode();

  bool _isSaving = false;

  static const int _maxMemoLength = 100;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _memoFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _memoController.dispose();
    _memoFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // 거래 요약
            _buildTransactionSummary(context),

            const Divider(height: 1),

            // 메모 입력 영역
            Expanded(child: _buildMemoInput(context)),

            // 저장 버튼
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBar(
      title: Text(l10n.memo),
      leading: IconButton(
        icon: const Icon(PhosphorIconsThin.arrowLeft),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildTransactionSummary(BuildContext context) {
    final theme = Theme.of(context);
    final formattedAmount = CurrencyUtils.formatWithSymbol(
      widget.amountInMinorUnits,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isIncome ? '+$formattedAmount' : '-$formattedAmount',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: widget.isIncome
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(widget.transactionDate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  (widget.isIncome
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error)
                      .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.isIncome
                  ? PhosphorIconsThin.arrowUp
                  : PhosphorIconsThin.arrowDown,
              color: widget.isIncome
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildMemoInput(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메모 라벨
          Row(
            children: [
              Icon(
                PhosphorIconsThin.notepad,
                size: 20,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.memo,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const Spacer(),
              // 글자 수 카운터
              Text(
                '${_memoController.text.length}/$_maxMemoLength',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 메모 입력 필드
          TextField(
            controller: _memoController,
            focusNode: _memoFocusNode,
            maxLength: _maxMemoLength,
            maxLines: 4,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l10n.memoHint,
              counterText: '', // maxLength 카운터 숨김 (위에서 직접 표시)
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
            onChanged: (value) {
              setState(() {}); // 글자 수 카운터 업데이트
            },
            onSubmitted: (_) {
              _memoFocusNode.unfocus();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: _isSaving ? null : _onSavePressed,
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  l10n.save,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _onSavePressed() async {
    // 키보드 닫기
    _memoFocusNode.unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      // 거래 저장
      final transaction = TransactionsCompanion.insert(
        amount: widget.amountInMinorUnits,
        currencyCode: Value(CurrencyUtils.currentCurrency.code),
        isIncome: widget.isIncome,
        categoryId: widget.categoryId,
        memo: Value(
          _memoController.text.trim().isEmpty
              ? null
              : _memoController.text.trim(),
        ),
        transactionDate: widget.transactionDate,
      );

      await widget.database.insertTransaction(transaction);

      if (!mounted) return;

      // 성공 피드백
      HapticFeedback.mediumImpact();

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isIncome ? l10n.incomeAdded : l10n.expenseAdded,
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // 홈 화면으로 복귀 (모든 거래 입력 화면 닫기)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (!mounted) return;

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorOccurred),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
