require 'http'

class GNewsService
  BASE_URL = 'https://gnews.io/api/v4'.freeze

  def initialize
    @api_key = fetch_api_key
  end

  # ニュースを取得するメインメソッド（キャッシュ対応）
  def fetch_news(topic, options = {})
    language = options[:language] || 'ja'       # 言語（デフォルト: 日本語）
    max = options[:max] || 10                   # 最大取得件数（デフォルト: 10）
    endpoint = options[:endpoint] || '/search'  # エンドポイント（デフォルト: /search）

    cache_key = "gnews/#{topic}/#{language}/#{max}"  # キャッシュキーを作成

    # キャッシュがあれば取得、なければAPIリクエスト
    result = Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      Rails.logger.info("Cache miss for key: #{cache_key}. Fetching data from API.")

      response = HTTP.get("#{BASE_URL}#{endpoint}", params: {
        q: topic,
        lang: language,
        max: max,
        token: @api_key
      })
      handle_response(response)
    end

    # キャッシュがある場合のログ出力
    Rails.logger.info("Cache hit for key: #{cache_key}. Returning cached data.") if Rails.cache.exist?(cache_key)

    result
  rescue StandardError => e
    Rails.logger.error "GNews API Error: #{e.message}"
    []
  end

  private

  # APIキーを環境変数（本番）またはcredentials（開発）から取得
  def fetch_api_key
    ENV['GNEWS_API_KEY'] || Rails.application.credentials.dig(:gnews, :api_key)
  end

  # レスポンスのエラーハンドリング
  def handle_response(response)
    if response.status.success?
      JSON.parse(response.body.to_s)['articles']
    else
      Rails.logger.error "GNews API Response Error: #{response.status} - #{response.body.to_s}"
      []
    end
  end
end
