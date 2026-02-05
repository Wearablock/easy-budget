#!/usr/bin/env ruby
# frozen_string_literal: true

# Google Play IAP 상품 동기화 스크립트
#
# 사용법:
#   ruby sync_iap.rb [create|update|get|list]
#
# 필요 조건:
#   1. Google Play Console에서 서비스 계정 생성
#   2. 서비스 계정 JSON 키 파일 다운로드
#   3. 환경 변수 설정: GOOGLE_PLAY_JSON_KEY_PATH
#
# 설치:
#   gem install google-apis-androidpublisher_v3

require 'json'
require 'google/apis/androidpublisher_v3'

# ============================================================
# 설정
# ============================================================

PACKAGE_NAME = 'com.wearablock.easy_budget'  # 앱 패키지명 (실제 값으로 변경)
IAP_DIR = File.dirname(__FILE__)

# ============================================================
# Google Play API 클라이언트
# ============================================================

class GooglePlayIAPSync
  def initialize
    @service = Google::Apis::AndroidpublisherV3::AndroidPublisherService.new
    @service.authorization = authorize
  end

  def authorize
    key_path = ENV['GOOGLE_PLAY_JSON_KEY_PATH']

    unless key_path && File.exist?(key_path)
      puts "❌ 서비스 계정 키 파일을 찾을 수 없습니다."
      puts "   환경 변수 GOOGLE_PLAY_JSON_KEY_PATH를 설정하세요."
      puts ""
      puts "   예시:"
      puts "   export GOOGLE_PLAY_JSON_KEY_PATH=/path/to/service-account.json"
      exit 1
    end

    Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(key_path),
      scope: 'https://www.googleapis.com/auth/androidpublisher'
    )
  end

  # 모든 IAP 상품 조회
  def list_products
    puts "📋 IAP 상품 목록 조회 중..."

    response = @service.list_inappproducts(PACKAGE_NAME)

    if response.inappproduct.nil? || response.inappproduct.empty?
      puts "   등록된 상품이 없습니다."
      return
    end

    response.inappproduct.each do |product|
      puts "   - #{product.sku}: #{product.status}"
    end
  end

  # 특정 상품 조회
  def get_product(sku)
    puts "🔍 상품 조회: #{sku}"

    begin
      product = @service.get_inappproduct(PACKAGE_NAME, sku)
      puts JSON.pretty_generate(product.to_h)
    rescue Google::Apis::ClientError => e
      puts "❌ 상품을 찾을 수 없습니다: #{e.message}"
    end
  end

  # 상품 생성
  def create_product(json_file)
    data = load_product_json(json_file)
    sku = data['sku']

    puts "➕ 상품 생성: #{sku}"

    product = build_product(data)

    begin
      @service.insert_inappproduct(PACKAGE_NAME, product)
      puts "✅ 상품이 생성되었습니다: #{sku}"
    rescue Google::Apis::ClientError => e
      if e.message.include?('already exists')
        puts "⚠️  상품이 이미 존재합니다. update 명령을 사용하세요."
      else
        puts "❌ 생성 실패: #{e.message}"
      end
    end
  end

  # 상품 업데이트
  def update_product(json_file)
    data = load_product_json(json_file)
    sku = data['sku']

    puts "🔄 상품 업데이트: #{sku}"

    product = build_product(data)

    begin
      @service.update_inappproduct(PACKAGE_NAME, sku, product)
      puts "✅ 상품이 업데이트되었습니다: #{sku}"
    rescue Google::Apis::ClientError => e
      if e.message.include?('not found')
        puts "⚠️  상품이 존재하지 않습니다. create 명령을 사용하세요."
      else
        puts "❌ 업데이트 실패: #{e.message}"
      end
    end
  end

  # 상품 생성 또는 업데이트 (upsert)
  def upsert_product(json_file)
    data = load_product_json(json_file)
    sku = data['sku']

    puts "📦 상품 동기화: #{sku}"

    # 먼저 존재 여부 확인
    begin
      @service.get_inappproduct(PACKAGE_NAME, sku)
      update_product(json_file)
    rescue Google::Apis::ClientError
      create_product(json_file)
    end
  end

  # 디렉토리 내 모든 상품 동기화
  def sync_all
    puts "🚀 모든 IAP 상품 동기화 시작"
    puts ""

    json_files = Dir.glob(File.join(IAP_DIR, '*.json'))

    if json_files.empty?
      puts "❌ JSON 파일을 찾을 수 없습니다."
      return
    end

    json_files.each do |file|
      upsert_product(file)
      puts ""
    end

    puts "✅ 동기화 완료!"
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

  def build_product(data)
    product = Google::Apis::AndroidpublisherV3::InAppProduct.new

    product.sku = data['sku']
    product.status = data['status'] || 'active'
    product.purchase_type = data['purchaseType'] || 'managedUser'
    product.package_name = PACKAGE_NAME

    # 기본 가격 설정
    if data['defaultPrice']
      product.default_price = Google::Apis::AndroidpublisherV3::Price.new(
        price_micros: data['defaultPrice']['priceMicros'],
        currency: data['defaultPrice']['currency']
      )
    end

    # 다국어 설명 설정
    if data['listings']
      product.listings = {}

      data['listings'].each do |locale, listing|
        product.listings[locale] = Google::Apis::AndroidpublisherV3::InAppProductListing.new(
          title: listing['title'],
          description: listing['description']
        )
      end
    end

    product
  end
end

# ============================================================
# 메인
# ============================================================

def print_usage
  puts <<~USAGE
    Google Play IAP 상품 동기화 스크립트

    사용법:
      ruby sync_iap.rb <command> [options]

    명령어:
      sync              모든 JSON 파일의 상품을 동기화 (생성 또는 업데이트)
      create <file>     새 상품 생성
      update <file>     기존 상품 업데이트
      get <sku>         상품 정보 조회
      list              모든 상품 목록 조회

    예시:
      ruby sync_iap.rb sync
      ruby sync_iap.rb create easy_budget_premium.json
      ruby sync_iap.rb get easy_budget_premium

    환경 변수:
      GOOGLE_PLAY_JSON_KEY_PATH  서비스 계정 JSON 키 파일 경로
  USAGE
end

if __FILE__ == $0
  command = ARGV[0]

  case command
  when 'sync'
    GooglePlayIAPSync.new.sync_all
  when 'create'
    file = ARGV[1] || 'easy_budget_premium.json'
    GooglePlayIAPSync.new.create_product(file)
  when 'update'
    file = ARGV[1] || 'easy_budget_premium.json'
    GooglePlayIAPSync.new.update_product(file)
  when 'get'
    sku = ARGV[1]
    if sku.nil?
      puts "❌ SKU를 지정하세요."
      exit 1
    end
    GooglePlayIAPSync.new.get_product(sku)
  when 'list'
    GooglePlayIAPSync.new.list_products
  else
    print_usage
  end
end
