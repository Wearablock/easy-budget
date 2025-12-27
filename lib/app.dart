import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/main/main_screen.dart';
import 'package:easy_budget/screens/onboarding/currency_selection_screen.dart';
import 'package:easy_budget/services/preferences_service.dart';
import 'package:easy_budget/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class EasyBudgetApp extends StatefulWidget {
  const EasyBudgetApp({super.key});

  /// 앱 전역 ScaffoldMessenger 키
  /// 화면 전환 시에도 스낵바가 정상 작동하도록 함
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  State<EasyBudgetApp> createState() => _EasyBudgetAppState();
}

class _EasyBudgetAppState extends State<EasyBudgetApp> {
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _showOnboarding = PreferencesService.isFirstRun;
  }

  void _onOnboardingComplete() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Budget',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: EasyBudgetApp.scaffoldMessengerKey,

      // 테마 설정
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // 다국어 설정
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
        // 추후 다른 언어 추가
      ],

      home: _showOnboarding
          ? CurrencySelectionScreen(onComplete: _onOnboardingComplete)
          : const MainScreen(),
    );
  }
}
