import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 인앱 결제 서비스
///
/// 광고 제거 상품의 구매 및 복원을 처리합니다.
class IAPService extends ChangeNotifier {
  // ============================================================
  // 싱글톤 패턴
  // ============================================================

  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  // ============================================================
  // 상수
  // ============================================================

  /// 광고 제거 상품 ID (iOS/Android 동일)
  static const String removeAdsProductId = 'easy_budget_premium';

  /// 프리미엄 상태 저장 키
  static const String _premiumKey = 'is_premium';

  // ============================================================
  // 상태
  // ============================================================

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _available = false;
  List<ProductDetails> _products = [];
  bool _isPremium = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  /// IAP 사용 가능 여부
  bool get isAvailable => _available;

  /// 상품 목록
  List<ProductDetails> get products => _products;

  /// 프리미엄 여부 (광고 제거 구매 완료)
  bool get isPremium => _isPremium;

  /// 로딩 중 여부
  bool get isLoading => _isLoading;

  /// 초기화 완료 여부
  bool get isInitialized => _isInitialized;

  /// 광고 제거 상품
  ProductDetails? get removeAdsProduct {
    try {
      return _products.firstWhere((p) => p.id == removeAdsProductId);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // 초기화
  // ============================================================

  /// IAP 초기화 (앱 시작 시 한 번 호출)
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. 저장된 프리미엄 상태 로드
    await _loadPremiumStatus();

    // 2. IAP 사용 가능 여부 확인
    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('[IAPService] IAP를 사용할 수 없습니다.');
      _isInitialized = true;
      notifyListeners();
      return;
    }

    // 3. 구매 스트림 구독 (구매 상태 변경 감지)
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint('[IAPService] 구매 스트림 오류: $error');
      },
    );

    // 4. 상품 정보 로드
    await _loadProducts();

    // 5. 이전 구매 복원 (앱 시작 시 자동)
    await restorePurchases();

    _isInitialized = true;
    notifyListeners();
    debugPrint('[IAPService] 초기화 완료 (프리미엄: $_isPremium)');
  }

  /// 상품 정보 로드
  Future<void> _loadProducts() async {
    const Set<String> productIds = {removeAdsProductId};

    try {
      final response = await _iap.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('[IAPService] 찾을 수 없는 상품: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      debugPrint('[IAPService] 로드된 상품: ${_products.map((p) => '${p.id}: ${p.price}').toList()}');
      notifyListeners();
    } catch (e) {
      debugPrint('[IAPService] 상품 로드 실패: $e');
    }
  }

  /// 저장된 프리미엄 상태 로드
  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    notifyListeners();
  }

  /// 프리미엄 상태 저장
  Future<void> _savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);
    _isPremium = isPremium;
    notifyListeners();
    debugPrint('[IAPService] 프리미엄 상태 저장: $isPremium');
  }

  // ============================================================
  // 구매
  // ============================================================

  /// 광고 제거 구매
  Future<bool> purchaseRemoveAds() async {
    final product = removeAdsProduct;
    if (product == null) {
      debugPrint('[IAPService] 광고 제거 상품을 찾을 수 없습니다.');
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final purchaseParam = PurchaseParam(productDetails: product);
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('[IAPService] 구매 시작 실패: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 구매 업데이트 처리
  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      await _handlePurchase(purchase);
    }
  }

  /// 개별 구매 처리
  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.pending) {
      // 결제 대기 중
      _isLoading = true;
      notifyListeners();
      debugPrint('[IAPService] 구매 대기 중: ${purchase.productID}');
    } else if (purchase.status == PurchaseStatus.error) {
      // 구매 오류
      _isLoading = false;
      notifyListeners();
      debugPrint('[IAPService] 구매 오류: ${purchase.error}');
    } else if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      // 구매 완료 또는 복원
      _isLoading = false;
      if (purchase.productID == removeAdsProductId) {
        await _savePremiumStatus(true);
        debugPrint('[IAPService] 광고 제거 활성화됨');
      }
    } else if (purchase.status == PurchaseStatus.canceled) {
      // 구매 취소
      _isLoading = false;
      notifyListeners();
      debugPrint('[IAPService] 구매 취소됨: ${purchase.productID}');
    }

    // ⚠️ 중요: 구매 완료 처리 (필수!)
    // 이 메서드를 호출하지 않으면 스토어에서 환불 처리됨
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
      debugPrint('[IAPService] completePurchase() 호출됨');
    }
  }

  // ============================================================
  // 복원
  // ============================================================

  /// 이전 구매 복원
  Future<void> restorePurchases() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _iap.restorePurchases();
      debugPrint('[IAPService] 구매 복원 요청됨');
    } catch (e) {
      debugPrint('[IAPService] 구매 복원 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // 정리
  // ============================================================

  /// 리소스 정리
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
