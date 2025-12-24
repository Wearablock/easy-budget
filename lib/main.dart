import 'package:easy_budget/app.dart';
import 'package:easy_budget/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await PreferencesService.init();

  // 저장된 통화 설정 적용
  PreferencesService.applySavedCurrency();

  runApp(const EasyBudgetApp());
}
