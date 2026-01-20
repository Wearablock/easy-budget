import 'package:easy_budget/app.dart';
import 'package:easy_budget/constants/app_colors.dart';
import 'package:easy_budget/constants/app_limits.dart';
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/models/currency_config.dart';
import 'package:easy_budget/screens/transaction/category_selection_screen.dart';
import 'package:easy_budget/services/transaction_notifier.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:easy_budget/widgets/amount_input/amount_display.dart';
import 'package:easy_budget/widgets/amount_input/number_keypad.dart';
import 'package:easy_budget/widgets/transaction_type_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddTransactionScreen extends StatefulWidget {
  final AppDatabase database;
  final Transaction? existingTransaction;

  const AddTransactionScreen({
    super.key,
    required this.database,
    this.existingTransaction,
  });

  bool get isEditMode => existingTransaction != null;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _integerPart = '';
  String _decimalPart = '';
  bool _hasDecimalPoint = false;
  bool _isIncome = false;

  // 수정 모드용 변수들
  int? _existingCategoryId;
  DateTime? _existingDate;

  CurrencyConfig get _currency => CurrencyUtils.currentCurrency;

  @override
  void initState() {
    super.initState();

    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _isIncome = tx.isIncome;

      _loadAmountFromTransaction(tx.amount);

      _existingCategoryId = tx.categoryId;
      _existingDate = tx.transactionDate;
    }
  }

  void _loadAmountFromTransaction(int amountInMinorUnits) {
    if (_currency.hasDecimals) {
      final multiplier = _currency.minorUnitMultiplier;
      _integerPart = (amountInMinorUnits ~/ multiplier).toString();
      _decimalPart = (amountInMinorUnits % multiplier).toString().padLeft(
        _currency.decimalPlaces,
        '0',
      );
      if (_decimalPart != '0' * _currency.decimalPlaces) {
        _hasDecimalPoint = true;
      }
    } else {
      _integerPart = amountInMinorUnits.toString();
    }
  }

  int get _amountInMinorUnits {
    if (_integerPart.isEmpty && _decimalPart.isEmpty) return 0;

    final intValue = int.tryParse(_integerPart) ?? 0;

    if (!_currency.hasDecimals) {
      return intValue;
    }

    String paddedDecimal = _decimalPart.padRight(_currency.decimalPlaces, '0');
    if (paddedDecimal.length > _currency.decimalPlaces) {
      paddedDecimal = paddedDecimal.substring(0, _currency.decimalPlaces);
    }
    final decimalValue = int.tryParse(paddedDecimal) ?? 0;

    return (intValue * _currency.minorUnitMultiplier) + decimalValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 화면 높이에 따라 레이아웃 조정
            final availableHeight = constraints.maxHeight;
            final isCompact = availableHeight < 500;

            return Column(
              children: [
                // 수입/지출 토글
                TransactionTypeToggle(
                  isIncome: _isIncome,
                  onChanged: (value) => setState(() => _isIncome = value),
                ),

                // 금액 표시 - 유연하게 축소 가능
                Flexible(
                  flex: isCompact ? 1 : 2,
                  child: AmountDisplay(
                    amountInMinorUnits: _amountInMinorUnits,
                    isIncome: _isIncome,
                  ),
                ),

                // 숫자 키패드 - 최소 크기 보장
                Flexible(
                  flex: 3,
                  child: NumberKeypad(
                    onKeyPressed: _onKeyPressed,
                    onDeletePressed: _onDeletePressed,
                    onDeleteLongPressed: _onClearAll,
                    onDecimalPressed: _currency.hasDecimals
                        ? _onDecimalPressed
                        : null,
                    decimalSeparator: _currency.decimalSeparator,
                    showDoubleZero: !_currency.hasDecimals,
                    compact: isCompact,
                  ),
                ),

                _buildNextButton(context),
              ],
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBar(
      title: Text(
        widget.isEditMode ? l10n.editTransaction : l10n.addTransaction,
      ),
      leading: IconButton(
        icon: const Icon(PhosphorIconsThin.x),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (widget.isEditMode)
          IconButton(
            onPressed: () => _showDeleteConfirmation(context),
            icon: const Icon(PhosphorIconsThin.trash),
          ),
        // 화폐 표시 (추후 탭하면 화폐 선택 가능)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              _currency.code,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

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
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteTransaction();
    }
  }

  Future<void> _deleteTransaction() async {
    final l10n = AppLocalizations.of(context);
    final messenger = EasyBudgetApp.scaffoldMessengerKey.currentState;

    try {
      await widget.database.softDeleteTransaction(
        widget.existingTransaction!.id,
      );

      if (!mounted) return;

      HapticFeedback.mediumImpact();

      messenger?.showSnackBar(
        SnackBar(
          content: Text(l10n.transactionDeleted),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 거래 변경 알림
      TransactionNotifier().notifyTransactionChanged();

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      messenger?.showSnackBar(
        SnackBar(
          content: Text(l10n.errorOccurred),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  Widget _buildNextButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEnabled = _amountInMinorUnits > 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: isEnabled ? _onNextPressed : null,
          child: Text(
            l10n.next,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (_hasDecimalPoint && _currency.hasDecimals) {
        // 소수부 입력
        if (_decimalPart.length < _currency.decimalPlaces) {
          _decimalPart += key;
        }
      } else {
        // 정수부 입력
        // 첫 입력이 0이고 00이 아닌 경우
        if (_integerPart.isEmpty && key == '0') {
          _integerPart = '0';
          return;
        }
        // 0으로 시작하는 경우 대체
        if (_integerPart == '0' && key != '00') {
          _integerPart = key;
          return;
        }

        // 최대 금액 체크
        final newInteger = _integerPart + key;
        if ((int.tryParse(newInteger) ?? 0) > AppLimits.maxDisplayAmount) return;

        _integerPart = newInteger;
      }
    });
  }

  void _onDecimalPressed() {
    if (!_currency.hasDecimals) return;

    setState(() {
      if (!_hasDecimalPoint) {
        _hasDecimalPoint = true;
        if (_integerPart.isEmpty) {
          _integerPart = '0';
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_hasDecimalPoint && _decimalPart.isNotEmpty) {
        // 소수부 삭제
        _decimalPart = _decimalPart.substring(0, _decimalPart.length - 1);
      } else if (_hasDecimalPoint) {
        // 소수점 삭제
        _hasDecimalPoint = false;
      } else if (_integerPart.isNotEmpty) {
        // 정수부 삭제
        _integerPart = _integerPart.substring(0, _integerPart.length - 1);
      }
    });
  }

  // 전체 삭제 (롱프레스)
  void _onClearAll() {
    setState(() {
      _integerPart = '';
      _decimalPart = '';
      _hasDecimalPoint = false;
    });
  }

  void _onNextPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategorySelectionScreen(
          database: widget.database,
          isIncome: _isIncome,
          amountInMinorUnits: _amountInMinorUnits,
          existingTransaction: widget.existingTransaction,
          initialCategoryId: _existingCategoryId,
          initialDate: _existingDate,
        ),
      ),
    );
  }
}
