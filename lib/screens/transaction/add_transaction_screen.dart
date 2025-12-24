import 'package:easy_budget/constants/app_colors.dart';
import 'package:easy_budget/database/database.dart';
import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/models/currency_config.dart';
import 'package:easy_budget/screens/transaction/category_selection_screen.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:easy_budget/widgets/amount_input/amount_display.dart';
import 'package:easy_budget/widgets/amount_input/number_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddTransactionScreen extends StatefulWidget {
  final AppDatabase database;

  const AddTransactionScreen({super.key, required this.database});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _integerPart = '';
  String _decimalPart = '';
  bool _hasDecimalPoint = false;

  bool _isIncome = false;

  CurrencyConfig get _currency => CurrencyUtils.currentCurrency;

  static const int _maxDisplayAmount = 999999999;

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
        child: Column(
          children: [
            // 수입/지출 토글
            _buildTransactionTypeToggle(context),

            Expanded(
              flex: 2,
              child: AmountDisplay(
                amountInMinorUnits: _amountInMinorUnits,
                isIncome: _isIncome,
              ),
            ),

            Expanded(
              flex: 3,
              child: NumberKeypad(
                onKeyPressed: _onKeyPressed,
                onDeletePressed: _onDeletePressed,
                onDeleteLongPressed: _onClearAll,
                // 소수점 화폐인 경우에만 소수점 버튼 표시
                onDecimalPressed: _currency.hasDecimals
                    ? _onDecimalPressed
                    : null,
                decimalSeparator: _currency.decimalSeparator,
                showDoubleZero: !_currency.hasDecimals,
              ),
            ),

            _buildNextButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeToggle(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // 지출 버튼
            Expanded(
              child: GestureDetector(
                onTap: () => _onToggleType(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: !_isIncome ? AppColors.expense : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIconsBold.minus,
                          size: 18,
                          color: !_isIncome
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.expense,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: !_isIncome
                                ? Colors.white
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 수입 버튼
            Expanded(
              child: GestureDetector(
                onTap: () => _onToggleType(true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: _isIncome ? AppColors.income : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIconsBold.plus,
                          size: 18,
                          color: _isIncome
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.income,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _isIncome
                                ? Colors.white
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onToggleType(bool isIncome) {
    if (_isIncome != isIncome) {
      HapticFeedback.lightImpact();
      setState(() {
        _isIncome = isIncome;
      });
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBar(
      title: Text(l10n.addTransaction),
      leading: IconButton(
        icon: const Icon(PhosphorIconsThin.x),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
        if ((int.tryParse(newInteger) ?? 0) > _maxDisplayAmount) return;

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
        ),
      ),
    );
  }
}
