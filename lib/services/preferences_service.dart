import 'package:easy_budget/models/currency_config.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyIsFirstRun = 'is_first_run';
  static const String _keyCurrencyCode = 'currency_code';

  static late SharedPreferences _prefs;

  /// SharedPreferences 초기화 (앱 시작 시 호출)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 첫 실행 여부 확인
  static bool get isFirstRun {
    return _prefs.getBool(_keyIsFirstRun) ?? true;
  }

  /// 첫 실행 완료 표시
  static Future<void> setFirstRunComplete() async {
    await _prefs.setBool(_keyIsFirstRun, false);
  }

  /// 저장된 통화 코드 가져오기
  static String get currencyCode {
    return _prefs.getString(_keyCurrencyCode) ?? 'USD';
  }

  /// 통화 코드 저장
  static Future<void> setCurrencyCode(String code) async {
    await _prefs.setString(_keyCurrencyCode, code);
    // CurrencyUtils에도 반영
    CurrencyUtils.setCurrency(CurrencyConfig.fromCode(code));
  }

  /// 저장된 설정으로 CurrencyUtils 초기화
  static void applySavedCurrency() {
    final code = currencyCode;
    CurrencyUtils.setCurrency(CurrencyConfig.fromCode(code));
  }
}
