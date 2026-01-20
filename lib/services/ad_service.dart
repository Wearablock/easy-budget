import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 광고 서비스
///
/// 테스트/프로덕션 ID 자동 분리:
/// - Debug 모드: 테스트 광고 ID 사용
/// - Release 모드: 실제 광고 ID 사용
class AdService extends ChangeNotifier {
  // 싱글톤 패턴
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // ========== 광고 ID 설정 ==========

  /// 실제 배포용 광고 단위 ID (AdMob 콘솔에서 생성 후 교체)
  static const String _productionBannerAdUnitIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: 실제 Android 배너 ID로 교체
  static const String _productionBannerAdUnitIdIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: 실제 iOS 배너 ID로 교체

  /// 테스트용 광고 단위 ID (Google 공식 테스트 ID)
  static const String _testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';

  /// 현재 환경에 맞는 배너 광고 단위 ID 반환
  String get bannerAdUnitId {
    if (kDebugMode) {
      // 디버그 모드: 테스트 ID 사용
      return Platform.isAndroid
          ? _testBannerAdUnitIdAndroid
          : _testBannerAdUnitIdIOS;
    } else {
      // 릴리즈 모드: 실제 ID 사용
      return Platform.isAndroid
          ? _productionBannerAdUnitIdAndroid
          : _productionBannerAdUnitIdIOS;
    }
  }

  // ========== 상태 관리 ==========

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _isInitialized = false;
  double? _screenWidth;

  bool get isBannerAdLoaded => _isBannerAdLoaded;
  BannerAd? get bannerAd => _isBannerAdLoaded ? _bannerAd : null;
  bool get isInitialized => _isInitialized;

  // ========== 초기화 ==========

  /// AdMob SDK 초기화 (앱 시작 시 한 번 호출)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // iOS 14.5+ ATT 권한 요청
      if (Platform.isIOS) {
        await _requestTrackingAuthorization();
      }

      // AdMob SDK 초기화
      await MobileAds.instance.initialize();
      _isInitialized = true;

      debugPrint('[AdService] 초기화 완료 (${kDebugMode ? "테스트 모드" : "프로덕션 모드"})');
    } catch (e) {
      debugPrint('[AdService] 초기화 실패: $e');
      _isInitialized = false;
    }
  }

  /// iOS App Tracking Transparency 권한 요청
  Future<void> _requestTrackingAuthorization() async {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;

      if (status == TrackingStatus.notDetermined) {
        // 약간의 딜레이 후 권한 요청 (앱 시작 직후 요청 시 무시될 수 있음)
        await Future.delayed(const Duration(milliseconds: 500));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }

      debugPrint('[AdService] ATT 상태: $status');
    } catch (e) {
      debugPrint('[AdService] ATT 요청 실패: $e');
    }
  }

  // ========== 배너 광고 ==========

  /// Adaptive 배너 광고 로드
  /// [screenWidth]: 화면 너비 (MediaQuery.of(context).size.width)
  Future<void> loadBannerAd(double screenWidth) async {
    // 이미 같은 너비로 로드된 경우 스킵
    if (_isBannerAdLoaded && _screenWidth == screenWidth) return;
    _screenWidth = screenWidth;

    // 기존 광고 정리
    await _bannerAd?.dispose();
    _isBannerAdLoaded = false;
    notifyListeners();

    try {
      // Adaptive Banner 사이즈 계산 (화면 너비에 맞춤)
      final AdSize? adaptiveSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
        Orientation.portrait,
        screenWidth.toInt(),
      );

      // Adaptive 사이즈 실패 시 기본 배너 사용
      final AdSize adSize = adaptiveSize ?? AdSize.banner;

      _bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
            notifyListeners();
            debugPrint('[AdService] 배너 광고 로드 성공: ${adSize.width}x${adSize.height}');
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoaded = false;
            ad.dispose();
            notifyListeners();
            debugPrint('[AdService] 배너 광고 로드 실패: ${error.message}');
          },
          onAdOpened: (ad) => debugPrint('[AdService] 배너 광고 열림'),
          onAdClosed: (ad) => debugPrint('[AdService] 배너 광고 닫힘'),
          onAdClicked: (ad) => debugPrint('[AdService] 배너 광고 클릭'),
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      debugPrint('[AdService] 배너 광고 로드 예외: $e');
      _isBannerAdLoaded = false;
      notifyListeners();
    }
  }

  /// 배너 광고 해제
  Future<void> disposeBannerAd() async {
    await _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
    _screenWidth = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
    super.dispose();
  }
}
