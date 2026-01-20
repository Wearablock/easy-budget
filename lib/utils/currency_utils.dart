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

  /// 금액을 간략하게 표시 (예: ₩1.2M, $500K)
  static String formatCompact(int amount, {CurrencyConfig? currency}) {
    final config = currency ?? _currentCurrency;
    final absAmount = amount.abs();

    String formatted;

    if (absAmount >= 1000000000) {
      // 10억 이상: B (Billion)
      formatted = '${(absAmount / 1000000000).toStringAsFixed(1)}B';
    } else if (absAmount >= 1000000) {
      // 100만 이상: M (Million)
      formatted = '${(absAmount / 1000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000) {
      // 1000 이상: K (Thousand)
      formatted = '${(absAmount / 1000).toStringAsFixed(1)}K';
    } else {
      formatted = absAmount.toString();
    }

    // 소수점 .0 제거
    formatted = formatted.replaceAll('.0', '');

    // 통화 기호 추가
    final space = config.symbolSpaced ? ' ' : '';
    if (config.symbolBefore) {
      return '${amount < 0 ? '-' : ''}${config.symbol}$space$formatted';
    } else {
      return '${amount < 0 ? '-' : ''}$formatted$space${config.symbol}';
    }
  }

  /// 한국어 단위 사용 (만, 억)
  static String formatCompactKorean(int amount) {
    final absAmount = amount.abs();

    String formatted;

    if (absAmount >= 100000000) {
      // 1억 이상
      formatted = '${(absAmount / 100000000).toStringAsFixed(1)}억';
    } else if (absAmount >= 10000) {
      // 1만 이상
      formatted = '${(absAmount / 10000).toStringAsFixed(1)}만';
    } else {
      formatted = absAmount.toString();
    }

    // 소수점 .0 제거
    formatted = formatted.replaceAll('.0', '');

    return '${amount < 0 ? '-' : ''}₩$formatted';
  }
}
