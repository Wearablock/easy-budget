/// 앱에서 사용하는 URL 상수
///
/// 외부 링크, 문서 페이지 등의 URL을 정의합니다.
class AppUrls {
  AppUrls._();

  // ===== 기본 URL =====

  /// GitHub Pages 기본 URL
  static const String baseDocsUrl = 'https://wearablock.github.io/easy-budget';

  // ===== 정책 및 약관 =====

  /// 이용약관
  static const String termsUrl = '$baseDocsUrl/terms.html';

  /// 개인정보처리방침
  static const String privacyUrl = '$baseDocsUrl/privacy.html';

  /// 고객지원
  static const String supportUrl = '$baseDocsUrl/support.html';

  // ===== 스토어 링크 (향후 사용) =====

  // static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.wearablock.easybudget';
  // static const String appStoreUrl = 'https://apps.apple.com/app/easy-budget/id...';
}
