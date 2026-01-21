import 'package:easy_budget/services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Adaptive 배너 광고 위젯
///
/// 화면 너비에 맞춰 자동으로 크기가 조절되는 배너 광고를 표시합니다.
/// 광고 로드 전에는 빈 공간(placeholder)을 표시합니다.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AdService.showAds) return;
    // 화면 너비를 가져와서 광고 로드
    final width = MediaQuery.of(context).size.width;
    AdService().loadBannerAd(width);
  }

  @override
  Widget build(BuildContext context) {
    // 광고 비활성화 시 빈 위젯 반환
    if (!AdService.showAds) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: AdService(),
      builder: (context, _) {
        final bannerAd = AdService().bannerAd;

        // 광고 로드 전 placeholder
        if (bannerAd == null) {
          return const SizedBox(height: 50);
        }

        // 광고 표시
        return Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: bannerAd.size.height.toDouble(),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: AdWidget(ad: bannerAd),
        );
      },
    );
  }
}

/// SafeArea를 포함한 배너 광고 위젯
///
/// 하단 네비게이션 바 위 또는 Scaffold.bottomNavigationBar에 사용할 때
/// SafeArea를 자동으로 처리합니다.
class SafeBannerAdWidget extends StatefulWidget {
  const SafeBannerAdWidget({super.key});

  @override
  State<SafeBannerAdWidget> createState() => _SafeBannerAdWidgetState();
}

class _SafeBannerAdWidgetState extends State<SafeBannerAdWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AdService.showAds) return;
    final width = MediaQuery.of(context).size.width;
    AdService().loadBannerAd(width);
  }

  @override
  Widget build(BuildContext context) {
    // 광고 비활성화 시 빈 위젯 반환
    if (!AdService.showAds) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: AdService(),
      builder: (context, _) {
        final bannerAd = AdService().bannerAd;

        // 광고 로드 전 placeholder (SafeArea bottom padding 포함)
        if (bannerAd == null) {
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              top: false,
              child: const SizedBox(height: 50),
            ),
          );
        }

        // 광고 표시 with SafeArea
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: bannerAd.size.height.toDouble(),
              child: AdWidget(ad: bannerAd),
            ),
          ),
        );
      },
    );
  }
}
