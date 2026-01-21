import 'package:easy_budget/app.dart';
import 'package:easy_budget/services/ad_service.dart';
import 'package:easy_budget/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 스플래시 화면 유지
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initializeDateFormatting();
  await PreferencesService.init();

  // 저장된 통화 설정 적용
  PreferencesService.applySavedCurrency();

  // AdMob 초기화 (showAds가 true일 때만)
  if (AdService.showAds) {
    await AdService().initialize();
  }

  // 스플래시 화면 종료
  FlutterNativeSplash.remove();

  runApp(const EasyBudgetApp());
}
