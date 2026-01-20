import 'package:easy_budget/l10n/app_localizations.dart';
import 'package:easy_budget/screens/main/main_screen.dart';
import 'package:easy_budget/screens/onboarding/currency_selection_screen.dart';
import 'package:easy_budget/services/preferences_service.dart';
import 'package:easy_budget/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class EasyBudgetApp extends StatefulWidget {
  const EasyBudgetApp({super.key});

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // 상태 변경 콜백 (내부에서 설정됨)
  static void Function(ThemeMode)? _setThemeMode;
  static void Function(Locale?)? _setLocale;

  /// 테마 변경
  static void setThemeMode(ThemeMode mode) {
    _setThemeMode?.call(mode);
  }

  /// 언어 변경
  static void setLocale(Locale? locale) {
    _setLocale?.call(locale);
  }

  @override
  State<EasyBudgetApp> createState() => _EasyBudgetAppState();
}

class _EasyBudgetAppState extends State<EasyBudgetApp> {
  bool _showOnboarding = false;
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _showOnboarding = PreferencesService.isFirstRun;
    _themeMode = PreferencesService.themeMode;
    _locale = PreferencesService.locale;

    // 콜백 등록
    EasyBudgetApp._setThemeMode = _handleSetThemeMode;
    EasyBudgetApp._setLocale = _handleSetLocale;
  }

  @override
  void dispose() {
    // 콜백 해제
    EasyBudgetApp._setThemeMode = null;
    EasyBudgetApp._setLocale = null;
    super.dispose();
  }

  void _onOnboardingComplete() {
    setState(() {
      _showOnboarding = false;
    });
  }

  void _handleSetThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    PreferencesService.setThemeMode(mode);
  }

  void _handleSetLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
    // zh_Hant (Traditional Chinese) 처리
    String? code;
    if (locale != null) {
      if (locale.scriptCode == 'Hant') {
        code = 'zh_Hant';
      } else {
        code = locale.languageCode;
      }
    }
    PreferencesService.setLanguageCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: EasyBudgetApp.scaffoldMessengerKey,

      // 테마 설정
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,

      // 다국어 설정
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
        Locale('ja'),
        Locale('zh'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        Locale('de'),
        Locale('fr'),
        Locale('es'),
        Locale('pt'),
        Locale('it'),
        Locale('ru'),
        Locale('ar'),
        Locale('th'),
        Locale('vi'),
        Locale('id'),
      ],

      home: _showOnboarding
          ? CurrencySelectionScreen(onComplete: _onOnboardingComplete)
          : const MainScreen(),
    );
  }
}
