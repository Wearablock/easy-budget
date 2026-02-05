#!/usr/bin/env ruby
# frozen_string_literal: true

# App Store Connect IAP 현지화 동기화 스크립트
#
# 사용법:
#   ruby sync_iap_ios.rb [sync|list|get]
#
# 필요 조건:
#   1. App Store Connect API 키 생성
#   2. 환경 변수 설정:
#      - APP_STORE_CONNECT_KEY_ID
#      - APP_STORE_CONNECT_ISSUER_ID
#      - APP_STORE_CONNECT_KEY_PATH (p8 파일 경로)
#      - APP_STORE_APP_ID (앱의 Apple ID)
#
# 설치:
#   gem install jwt
#   gem install httparty

require 'json'
require 'jwt'
require 'httparty'
require 'base64'

# ============================================================
# 설정
# ============================================================

IAP_DIR = File.dirname(__FILE__)
BASE_URL = 'https://api.appstoreconnect.apple.com/v1'

# ============================================================
# App Store Connect API 클라이언트
# ============================================================

class AppStoreConnectIAPSync
  def initialize
    @key_id = ENV['APP_STORE_CONNECT_KEY_ID']
    @issuer_id = ENV['APP_STORE_CONNECT_ISSUER_ID']
    @key_path = ENV['APP_STORE_CONNECT_KEY_PATH']
    @app_id = ENV['APP_STORE_APP_ID']

    validate_env!
    @token = generate_jwt
  end

  def validate_env!
    missing = []
    missing << 'APP_STORE_CONNECT_KEY_ID' unless @key_id
    missing << 'APP_STORE_CONNECT_ISSUER_ID' unless @issuer_id
    missing << 'APP_STORE_CONNECT_KEY_PATH' unless @key_path
    missing << 'APP_STORE_APP_ID' unless @app_id

    return if missing.empty?

    puts "❌ 필수 환경 변수가 설정되지 않았습니다:"
    missing.each { |m| puts "   - #{m}" }
    puts ""
    puts "설정 방법은 README.md를 참조하세요."
    exit 1
  end

  def generate_jwt
    private_key = OpenSSL::PKey::EC.new(File.read(@key_path))

    payload = {
      iss: @issuer_id,
      iat: Time.now.to_i,
      exp: Time.now.to_i + 20 * 60, # 20분
      aud: 'appstoreconnect-v1'
    }

    JWT.encode(payload, private_key, 'ES256', { kid: @key_id, typ: 'JWT' })
  end

  def headers
    {
      'Authorization' => "Bearer #{@token}",
      'Content-Type' => 'application/json'
    }
  end

  # ============================================================
  # IAP 조회
  # ============================================================

  # 앱의 모든 인앱 구입 목록 조회
  def list_iaps
    puts "📋 인앱 구입 목록 조회 중..."

    response = HTTParty.get(
      "#{BASE_URL}/apps/#{@app_id}/inAppPurchasesV2",
      headers: headers
    )

    if response.success?
      iaps = response.parsed_response['data'] || []
      if iaps.empty?
        puts "   등록된 인앱 구입이 없습니다."
      else
        iaps.each do |iap|
          puts "   - #{iap['attributes']['productId']}: #{iap['attributes']['name']} (#{iap['id']})"
        end
      end
      iaps
    else
      puts "❌ 조회 실패: #{response.code}"
      puts response.body
      []
    end
  end

  # Product ID로 IAP 찾기
  def find_iap_by_product_id(product_id)
    iaps = list_iaps
    iaps.find { |iap| iap['attributes']['productId'] == product_id }
  end

  # IAP의 현지화 목록 조회
  def list_localizations(iap_id)
    puts "🌍 현지화 목록 조회 중..."

    response = HTTParty.get(
      "#{BASE_URL}/inAppPurchasesV2/#{iap_id}/inAppPurchaseLocalizations",
      headers: headers
    )

    if response.success?
      localizations = response.parsed_response['data'] || []
      localizations.each do |loc|
        attrs = loc['attributes']
        puts "   - #{attrs['locale']}: #{attrs['name']}"
      end
      localizations
    else
      puts "❌ 조회 실패: #{response.code}"
      []
    end
  end

  # ============================================================
  # 현지화 동기화
  # ============================================================

  # JSON 파일에서 현지화 동기화
  def sync_localizations(json_file)
    data = load_product_json(json_file)
    product_id = data['sku']

    puts "🔄 현지화 동기화: #{product_id}"
    puts ""

    # IAP 찾기
    iap = find_iap_by_product_id(product_id)
    unless iap
      puts "❌ 인앱 구입을 찾을 수 없습니다: #{product_id}"
      puts "   App Store Connect에서 먼저 상품을 생성하세요."
      return
    end

    iap_id = iap['id']
    puts "✅ IAP 발견: #{iap_id}"
    puts ""

    # 기존 현지화 조회
    existing = list_localizations(iap_id)
    existing_locales = existing.map { |l| l['attributes']['locale'] }
    puts ""

    # 각 언어별로 현지화 추가/업데이트
    listings = data['listings'] || {}

    # App Store Connect 언어 코드 매핑
    locale_mapping = {
      'en-US' => 'en-US',
      'ko' => 'ko',
      'ko-KR' => 'ko',
      'ja' => 'ja',
      'ja-JP' => 'ja',
      'zh-Hans' => 'zh-Hans',
      'zh-CN' => 'zh-Hans',
      'zh-Hant' => 'zh-Hant',
      'zh-TW' => 'zh-Hant',
      'de' => 'de-DE',
      'de-DE' => 'de-DE',
      'fr' => 'fr-FR',
      'fr-FR' => 'fr-FR',
      'es' => 'es-ES',
      'es-ES' => 'es-ES',
      'pt-BR' => 'pt-BR',
      'it' => 'it',
      'it-IT' => 'it',
      'ru' => 'ru',
      'ru-RU' => 'ru',
      'ar' => 'ar-SA',
      'th' => 'th',
      'vi' => 'vi',
      'id' => 'id'
    }

    listings.each do |locale, listing|
      asc_locale = locale_mapping[locale] || locale
      title = listing['title']
      description = listing['description']

      if existing_locales.include?(asc_locale)
        # 업데이트
        loc_id = existing.find { |l| l['attributes']['locale'] == asc_locale }['id']
        update_localization(loc_id, title, description)
      else
        # 생성
        create_localization(iap_id, asc_locale, title, description)
      end
    end

    puts ""
    puts "✅ 현지화 동기화 완료!"
  end

  # 현지화 생성
  def create_localization(iap_id, locale, name, description)
    print "   ➕ #{locale} 생성 중... "

    body = {
      data: {
        type: 'inAppPurchaseLocalizations',
        attributes: {
          locale: locale,
          name: name,
          description: description
        },
        relationships: {
          inAppPurchaseV2: {
            data: {
              type: 'inAppPurchases',
              id: iap_id
            }
          }
        }
      }
    }

    response = HTTParty.post(
      "#{BASE_URL}/inAppPurchaseLocalizations",
      headers: headers,
      body: body.to_json
    )

    if response.success?
      puts "✅"
    else
      puts "❌"
      error = JSON.parse(response.body)['errors']&.first
      puts "      #{error['detail']}" if error
    end
  end

  # 현지화 업데이트
  def update_localization(loc_id, name, description)
    print "   🔄 업데이트 중... "

    body = {
      data: {
        type: 'inAppPurchaseLocalizations',
        id: loc_id,
        attributes: {
          name: name,
          description: description
        }
      }
    }

    response = HTTParty.patch(
      "#{BASE_URL}/inAppPurchaseLocalizations/#{loc_id}",
      headers: headers,
      body: body.to_json
    )

    if response.success?
      puts "✅"
    else
      puts "❌"
      error = JSON.parse(response.body)['errors']&.first
      puts "      #{error['detail']}" if error
    end
  end

  private

  def load_product_json(json_file)
    file_path = File.expand_path(json_file, IAP_DIR)

    unless File.exist?(file_path)
      puts "❌ 파일을 찾을 수 없습니다: #{file_path}"
      exit 1
    end

    JSON.parse(File.read(file_path))
  end
end

# ============================================================
# 메인
# ============================================================

def print_usage
  puts <<~USAGE
    App Store Connect IAP 현지화 동기화 스크립트

    사용법:
      ruby sync_iap_ios.rb <command> [options]

    명령어:
      sync [file]       JSON 파일의 현지화를 App Store Connect에 동기화
      list              앱의 모든 인앱 구입 목록 조회
      localizations     특정 상품의 현지화 목록 조회

    예시:
      ruby sync_iap_ios.rb sync easy_budget_premium.json
      ruby sync_iap_ios.rb list

    환경 변수:
      APP_STORE_CONNECT_KEY_ID      API 키 ID
      APP_STORE_CONNECT_ISSUER_ID   Issuer ID
      APP_STORE_CONNECT_KEY_PATH    p8 키 파일 경로
      APP_STORE_APP_ID              앱의 Apple ID
  USAGE
end

if __FILE__ == $0
  command = ARGV[0]

  case command
  when 'sync'
    file = ARGV[1] || 'easy_budget_premium.json'
    AppStoreConnectIAPSync.new.sync_localizations(file)
  when 'list'
    AppStoreConnectIAPSync.new.list_iaps
  when 'localizations'
    product_id = ARGV[1] || 'easy_budget_premium'
    sync = AppStoreConnectIAPSync.new
    iap = sync.find_iap_by_product_id(product_id)
    if iap
      sync.list_localizations(iap['id'])
    end
  else
    print_usage
  end
end
