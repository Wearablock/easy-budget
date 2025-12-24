import 'package:easy_budget/models/currency_config.dart';

class CurrencyUtils {
  static CurrencyConfig _currentCurrency = CurrencyConfig.usd;

  static CurrencyConfig get currentCurrency => _currentCurrency;

  static void setCurrency(CurrencyConfig currency) {
    _currentCurrency = currency;
  }

  static void setCurrencyByCode(String code) {
    _currentCurrency = CurrencyConfig.fromCode(code);
  }

  static String formatAmount(int minorUnits, {CurrencyConfig? currency}) {
    final config = currency ?? _currentCurrency;

    if (config.decimalPlaces == 0) {
      return _formatWithThousands(minorUnits, config.thousandsSeparator);
    }

    final displayAmount = config.toDisplayAmount(minorUnits);
    final integerPart = displayAmount.truncate();
    final decimalPart =
        ((displayAmount - integerPart) * config.minorUnitMultiplier)
            .round()
            .toString()
            .padLeft(config.decimalPlaces, '0');

    final formattedInteger = _formatWithThousands(
      integerPart,
      config.thousandsSeparator,
    );

    return '$formattedInteger${config.decimalSeparator}$decimalPart';
  }

  static String formatWithSymbol(int minorUnits, {CurrencyConfig? currency}) {
    final config = currency ?? _currentCurrency;
    final formatted = formatAmount(minorUnits, currency: config);
    final space = config.symbolSpaced ? ' ' : '';

    if (config.symbolBefore) {
      return '${config.symbol}$space$formatted';
    } else {
      return '$formatted$space${config.symbol}';
    }
  }

  static String formatWithSign(
    int minorUnits,
    bool isIncome, {
    CurrencyConfig? currency,
  }) {
    final config = currency ?? _currentCurrency;
    final sign = isIncome ? '+' : '-';
    final formatted = formatAmount(minorUnits, currency: config);
    final space = config.symbolSpaced ? ' ' : '';

    if (config.symbolBefore) {
      return '$sign${config.symbol}$space$formatted';
    } else {
      return '$sign$formatted$space${config.symbol}';
    }
  }

  static String get currencySymbol => _currentCurrency.symbol;

  static bool get hasDecimals => _currentCurrency.hasDecimals;

  static int get decimalPlaces => _currentCurrency.decimalPlaces;

  static String _formatWithThousands(int value, String separator) {
    final text = value.abs().toString();
    final buffer = StringBuffer();
    final length = text.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(separator);
      }
      buffer.write(text[i]);
    }

    return value < 0 ? '-${buffer.toString()}' : buffer.toString();
  }

  static int parseInput(String input, {CurrencyConfig? currency}) {
    final config = currency ?? _currentCurrency;

    String cleaned = input.replaceAll(config.thousandsSeparator, '');

    if (config.hasDecimals) {
      cleaned = cleaned.replaceAll(config.decimalSeparator, '.');
      final value = double.tryParse(cleaned) ?? 0.0;
      return config.toMinorUnits(value);
    } else {
      return int.tryParse(cleaned) ?? 0;
    }
  }
}
