import 'dart:math';

/// 화폐 설정 모델
/// 각 화폐의 표시 형식과 소수점 자릿수를 정의합니다.
class CurrencyConfig {
  /// ISO 4217 화폐 코드 (예: "USD", "KRW", "EUR")
  final String code;

  /// 화폐 기호 (예: "$", "₩", "€")
  final String symbol;

  /// 소수점 자릿수 (예: KRW=0, USD=2, BHD=3)
  final int decimalPlaces;

  /// 기호가 금액 앞에 오는지 (true: $100, false: 100 €)
  final bool symbolBefore;

  /// 천 단위 구분자 (예: ",", ".", " ")
  final String thousandsSeparator;

  /// 소수점 구분자 (예: ".", ",")
  final String decimalSeparator;

  /// 기호와 금액 사이 공백 여부 (예: "€ 100" vs "€100")
  final bool symbolSpaced;

  const CurrencyConfig({
    required this.code,
    required this.symbol,
    required this.decimalPlaces,
    this.symbolBefore = true,
    this.thousandsSeparator = ',',
    this.decimalSeparator = '.',
    this.symbolSpaced = false,
  });

  /// 소수점이 필요한 화폐인지
  bool get hasDecimals => decimalPlaces > 0;

  /// 최소 단위의 승수 (예: decimalPlaces=2 → 100)
  int get minorUnitMultiplier => pow(10, decimalPlaces).toInt();

  /// 최소 단위를 표시 금액으로 변환
  double toDisplayAmount(int minorUnits) {
    if (decimalPlaces == 0) return minorUnits.toDouble();
    return minorUnits / minorUnitMultiplier;
  }

  /// 표시 금액을 최소 단위로 변환
  int toMinorUnits(double displayAmount) {
    return (displayAmount * minorUnitMultiplier).round();
  }

  // ===== 아시아 =====

  /// 한국 원
  static const krw = CurrencyConfig(
    code: 'KRW',
    symbol: '₩',
    decimalPlaces: 0,
    symbolBefore: true,
    thousandsSeparator: ',',
    decimalSeparator: '.',
  );

  /// 일본 엔
  static const jpy = CurrencyConfig(
    code: 'JPY',
    symbol: '¥',
    decimalPlaces: 0,
    symbolBefore: true,
    thousandsSeparator: ',',
    decimalSeparator: '.',
  );

  /// 중국 위안
  static const cny = CurrencyConfig(
    code: 'CNY',
    symbol: '¥',
    decimalPlaces: 2,
    symbolBefore: true,
    thousandsSeparator: ',',
    decimalSeparator: '.',
  );

  /// 대만 달러
  static const twd = CurrencyConfig(
    code: 'TWD',
    symbol: 'NT\$',
    decimalPlaces: 0,
    symbolBefore: true,
    thousandsSeparator: ',',
    decimalSeparator: '.',
  );

  /// 홍콩 달러
  static const hkd = CurrencyConfig(
    code: 'HKD',
    symbol: 'HK\$',
    decimalPlaces: 2,
    symbolBefore: true,
    thousandsSeparator: ',',
    decimalSeparator: '.',
  );

  /// 인도 루피
  static const inr = CurrencyConfig(
    code: 'INR',
    symbol: '₹',
    decimalPlaces: 2,
    symbolBefore: true,
    thousandsSeparator: ',',
    decimalSeparator: '.',
  );

  // ===== 동남아시아 =====

  /// 베트남 동
  static const vnd = CurrencyConfig(
    code: 'VND',
    symbol: '₫',
    decimalPlaces: 0,
    symbolBefore: false,
    thousandsSeparator: '.',
    decimalSeparator: ',',
    symbolSpaced: true,
  );

  /// 태국 바트
  static const thb = CurrencyConfig(
    code: 'THB',
    symbol: '฿',
    decimalPlaces: 2,
    symbolBefore: true,
    thousandsSeparator: ',',
    decimalSeparator: '.',
  );

  /// 인도네시아 루피아
  static const idr = CurrencyConfig(
    code: 'IDR',
    symbol: 'Rp',
    decimalPlaces: 0,
    symbolBefore: true,
    thousandsSeparator: '.',
    decimalSeparator: ',',
    symbolSpaced: true,
  );

  // ===== 북미 =====

  /// 미국 달러
  static const usd = CurrencyConfig(
    code: 'USD',
    symbol: '\$',
    decimalPlaces: 2,
    symbolBefore: true,
    thousandsSeparator: ',',
    decimalSeparator: '.',
  );

  /// 멕시코 페소
  static const mxn = CurrencyConfig(
    code: 'MXN',
    symbol: '\$',
    decimalPlaces: 2,
    symbolBefore: true,
    thousandsSeparator: ',',
    decimalSeparator: '.',
  );

  // ===== 남미 =====

  /// 브라질 헤알
  static const brl = CurrencyConfig(
    code: 'BRL',
    symbol: 'R\$',
    decimalPlaces: 2,
    symbolBefore: true,
    thousandsSeparator: '.',
    decimalSeparator: ',',
    symbolSpaced: true,
  );

  // ===== 유럽 =====

  /// 유로
  static const eur = CurrencyConfig(
    code: 'EUR',
    symbol: '€',
    decimalPlaces: 2,
    symbolBefore: false,
    thousandsSeparator: '.',
    decimalSeparator: ',',
    symbolSpaced: true,
  );

  /// 영국 파운드
  static const gbp = CurrencyConfig(
    code: 'GBP',
    symbol: '£',
    decimalPlaces: 2,
    symbolBefore: true,
    thousandsSeparator: ',',
    decimalSeparator: '.',
  );

  /// 스위스 프랑
  static const chf = CurrencyConfig(
    code: 'CHF',
    symbol: 'CHF',
    decimalPlaces: 2,
    symbolBefore: true,
    thousandsSeparator: "'",
    decimalSeparator: '.',
    symbolSpaced: true,
  );

  /// 러시아 루블
  static const rub = CurrencyConfig(
    code: 'RUB',
    symbol: '₽',
    decimalPlaces: 2,
    symbolBefore: false,
    thousandsSeparator: ' ',
    decimalSeparator: ',',
    symbolSpaced: true,
  );

  // ===== 중동 =====

  /// 사우디 리얄
  static const sar = CurrencyConfig(
    code: 'SAR',
    symbol: 'SR',
    decimalPlaces: 2,
    symbolBefore: false,
    thousandsSeparator: ',',
    decimalSeparator: '.',
    symbolSpaced: true,
  );

  /// 코드로 화폐 설정 조회
  static CurrencyConfig fromCode(String code) {
    return _currencyMap[code.toUpperCase()] ?? krw;
  }

  /// 지원하는 모든 화폐 목록
  static List<CurrencyConfig> get supportedCurrencies =>
      _currencyMap.values.toList();

  static const Map<String, CurrencyConfig> _currencyMap = {
    // 아시아
    'KRW': krw,
    'JPY': jpy,
    'CNY': cny,
    'TWD': twd,
    'HKD': hkd,
    'INR': inr,
    // 동남아시아
    'VND': vnd,
    'THB': thb,
    'IDR': idr,
    // 북미
    'USD': usd,
    'MXN': mxn,
    // 남미
    'BRL': brl,
    // 유럽
    'EUR': eur,
    'GBP': gbp,
    'CHF': chf,
    'RUB': rub,
    // 중동
    'SAR': sar,
  };
}
