import 'package:easy_budget/models/currency_config.dart';
import 'package:easy_budget/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyIsFirstRun = 'is_first_run';
  static const String _keyCurrencyCode = 'currency_code';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyThemeMode = 'theme_mode';

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

  /// 저장된 언어 코드 가져오기 (null이면 시스템 기본값)
  static String? get languageCode {
    return _prefs.getString(_keyLanguageCode);
  }

  /// 언어 코드 저장
  static Future<void> setLanguageCode(String? code) async {
    if (code == null) {
      await _prefs.remove(_keyLanguageCode);
    } else {
      await _prefs.setString(_keyLanguageCode, code);
    }
  }

  /// 저장된 Locale 가져오기
  static Locale? get locale {
    final code = languageCode;
    return code != null ? Locale(code) : null;
  }

  /// 저장된 테마 모드 가져오기
  static ThemeMode get themeMode {
    final value = _prefs.getString(_keyThemeMode);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// 테마 모드 저장
  static Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _prefs.setString(_keyThemeMode, value);
  }
}
