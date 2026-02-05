# Fastlane IAP 동기화 가이드

Google Play Console에 IAP 상품 정보를 자동으로 동기화합니다.

## 상품 ID

| 플랫폼 | 상품 ID |
|--------|---------|
| **Android** | `easy_budget_premium` |
| **iOS** | `easy_budget_premium` |

## 1. 사전 준비

### 1.1 Ruby Gem 설치

```bash
# Android용
gem install google-apis-androidpublisher_v3

# iOS용
gem install jwt httparty
```

### 1.2 Google Play Console 서비스 계정 설정

1. **Google Play Console** 접속
2. **설정** → **API 액세스** → **서비스 계정 관리**
3. **Google Cloud Platform에서 서비스 계정 만들기** 클릭
4. Google Cloud Console에서:
   - **서비스 계정 만들기** 클릭
   - 이름: `fastlane-iap` (자유롭게)
   - **만들기** → **완료**
5. 생성된 서비스 계정의 **키** 탭:
   - **키 추가** → **새 키 만들기** → **JSON** → **만들기**
   - JSON 파일 다운로드 (예: `google-play-service-account.json`)
6. Google Play Console로 돌아가서:
   - **서비스 계정 관리** → 방금 만든 계정 옆 **액세스 권한 부여**
   - **관리자** 권한 부여 (또는 **금융 데이터 관리** 최소 필요)

### 1.3 환경 변수 설정

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가
export GOOGLE_PLAY_JSON_KEY_PATH="/path/to/google-play-service-account.json"
```

```bash
source ~/.zshrc
```

### 1.4 iOS - App Store Connect API 설정

1. **App Store Connect** 접속
2. **사용자 및 액세스** → **키** → **App Store Connect API**
3. **키 생성** 클릭
   - 이름: `fastlane-iap`
   - 액세스: **관리자** 또는 **앱 관리**
4. **생성** 후:
   - **Key ID** 복사
   - **Issuer ID** 복사 (페이지 상단)
   - **API 키 다운로드** (.p8 파일, 한 번만 다운로드 가능!)

5. **앱의 Apple ID 확인**:
   - App Store Connect → 앱 → 앱 정보 → 일반 정보 → Apple ID

6. **환경 변수 설정**:

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가
export APP_STORE_CONNECT_KEY_ID="XXXXXXXXXX"
export APP_STORE_CONNECT_ISSUER_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export APP_STORE_CONNECT_KEY_PATH="/path/to/AuthKey_XXXXXXXXXX.p8"
export APP_STORE_APP_ID="123456789"
```

```bash
source ~/.zshrc
```

### 1.5 패키지명 확인

`fastlane/iap/sync_iap.rb` 파일의 `PACKAGE_NAME` 상수를 실제 앱 패키지명으로 수정:

```ruby
PACKAGE_NAME = 'com.wearablock.easy_budget'  # 실제 패키지명으로 변경
```

---

## 2. 사용법

### 통합 동기화 (Android + iOS)

```bash
# 모든 플랫폼에 IAP 현지화 동기화
fastlane sync_iap_all
```

### Android (Google Play)

```bash
# IAP 상품 동기화 (생성 또는 업데이트)
fastlane sync_iap

# 등록된 상품 목록 조회
fastlane list_iap

# 특정 상품 정보 조회
fastlane get_iap sku:easy_budget_premium
```

### iOS (App Store Connect)

```bash
# IAP 현지화 동기화
fastlane sync_iap_ios

# 등록된 상품 목록 조회
fastlane list_iap_ios
```

### Ruby 직접 실행

```bash
cd fastlane/iap

# Android
ruby sync_iap.rb sync
ruby sync_iap.rb list

# iOS
ruby sync_iap_ios.rb sync easy_budget_premium.json
ruby sync_iap_ios.rb list
```

---

## 3. 상품 JSON 파일 구조

`fastlane/iap/easy_budget_premium.json`:

```json
{
  "sku": "easy_budget_premium",
  "status": "active",
  "purchaseType": "managedUser",
  "defaultPrice": {
    "priceMicros": "4400000000",
    "currency": "KRW"
  },
  "listings": {
    "en-US": {
      "title": "Remove Ads",
      "description": "Permanently remove all ads..."
    },
    "ko-KR": {
      "title": "광고 제거",
      "description": "앱의 모든 광고를 영구적으로 제거합니다..."
    }
    // ... 기타 언어
  }
}
```

### 필드 설명

| 필드 | 설명 |
|------|------|
| `sku` | 상품 ID (코드와 일치해야 함) |
| `status` | `active` 또는 `inactive` |
| `purchaseType` | `managedUser` (비소모성) 또는 `subscription` |
| `defaultPrice.priceMicros` | 가격 × 1,000,000 (예: ₩4,400 = 4400000000) |
| `defaultPrice.currency` | 기본 통화 코드 |
| `listings` | 언어별 제목/설명 |

### 지원 언어 코드 (Google Play)

| 코드 | 언어 |
|------|------|
| `en-US` | 영어 (미국) |
| `ko-KR` | 한국어 |
| `ja-JP` | 일본어 |
| `zh-CN` | 중국어 (간체) |
| `zh-TW` | 중국어 (번체) |
| `de-DE` | 독일어 |
| `fr-FR` | 프랑스어 |
| `es-ES` | 스페인어 |
| `pt-BR` | 포르투갈어 (브라질) |
| `it-IT` | 이탈리아어 |
| `ru-RU` | 러시아어 |
| `ar` | 아랍어 |
| `th` | 태국어 |
| `vi` | 베트남어 |
| `id` | 인도네시아어 |

---

## 4. 문제 해결

### "서비스 계정 키 파일을 찾을 수 없습니다"

```bash
# 환경 변수 확인
echo $GOOGLE_PLAY_JSON_KEY_PATH

# 파일 존재 확인
ls -la $GOOGLE_PLAY_JSON_KEY_PATH
```

### "Permission denied" 또는 "403 Forbidden"

1. Google Play Console → API 액세스 → 서비스 계정 권한 확인
2. **관리자** 또는 **금융 데이터 관리** 권한 필요

### "Product already exists"

상품이 이미 있으면 `create` 대신 `update` 또는 `sync` 사용

### "Product not found"

상품이 없으면 `update` 대신 `create` 또는 `sync` 사용

---

## 5. 주의사항

- **가격 변경**: API로 가격을 변경하면 모든 지역에 즉시 적용됩니다
- **상품 삭제**: API로 상품을 삭제할 수 없습니다 (Play Console에서만 가능)
- **테스트**: 내부 테스트 트랙에서 먼저 테스트하세요
- **첫 업로드**: 앱을 최소 한 번 Play Console에 업로드해야 API 사용 가능
