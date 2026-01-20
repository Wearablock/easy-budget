import 'package:easy_budget/app.dart';
import 'package:easy_budget/constants/app_colors.dart';
import 'package:easy_budget/constants/app_limits.dart';
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/services/transaction_service.dart';
import 'package:easy_budget/widgets/transaction_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MemoInputScreen extends StatefulWidget {
  final AppDatabase database;
  final bool isIncome;
  final int amountInMinorUnits;
  final int categoryId;
  final DateTime transactionDate;

  /// 수정 모드용 기존 거래
  final Transaction? existingTransaction;

  const MemoInputScreen({
    super.key,
    required this.database,
    required this.isIncome,
    required this.amountInMinorUnits,
    required this.categoryId,
    required this.transactionDate,
    this.existingTransaction,
  });

  bool get isEditMode => existingTransaction != null;

  @override
  State<MemoInputScreen> createState() => _MemoInputScreenState();
}

class _MemoInputScreenState extends State<MemoInputScreen> {
  final TextEditingController _memoController = TextEditingController();
  final FocusNode _memoFocusNode = FocusNode();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // 수정 모드일 때 기존 메모 로드
    if (widget.existingTransaction?.memo != null) {
      _memoController.text = widget.existingTransaction!.memo!;
    }

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
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // 거래 요약
            TransactionSummary(
              amountInMinorUnits: widget.amountInMinorUnits,
              isIncome: widget.isIncome,
              transactionDate: widget.transactionDate,
            ),

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
                '${_memoController.text.length}/$AppLimits.maxMemoLength',
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
            maxLength: AppLimits.maxMemoLength,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
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
      final l10n = AppLocalizations.of(context);
      final memoText = _memoController.text.trim().isEmpty
          ? null
          : _memoController.text.trim();

      // 앱 전역 ScaffoldMessenger 사용 (화면 전환 후에도 스낵바 정상 작동)
      final messenger = EasyBudgetApp.scaffoldMessengerKey.currentState;
      final transactionService = TransactionService(widget.database);

      if (widget.isEditMode) {
        // 수정 모드
        await transactionService.updateTransaction(
          existingTransaction: widget.existingTransaction!,
          amount: widget.amountInMinorUnits,
          isIncome: widget.isIncome,
          categoryId: widget.categoryId,
          transactionDate: widget.transactionDate,
          memo: memoText,
        );

        if (!mounted) return;

        HapticFeedback.mediumImpact();
        messenger?.showSnackBar(
          SnackBar(
            content: Text(l10n.transactionUpdated),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // 추가 모드
        await transactionService.addTransaction(
          amount: widget.amountInMinorUnits,
          isIncome: widget.isIncome,
          categoryId: widget.categoryId,
          transactionDate: widget.transactionDate,
          memo: memoText,
        );

        if (!mounted) return;

        HapticFeedback.mediumImpact();
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              widget.isIncome ? l10n.incomeAdded : l10n.expenseAdded,
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

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
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }
}
