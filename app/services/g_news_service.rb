require 'http'

class GNewsService
  BASE_URL = 'https://gnews.io/api/v4'.freeze

  def initialize
    @api_key = fetch_api_key
  end

  # ニュースを取得するメインメソッド
  def fetch_news(topic, options = {})
    language = options[:language] || 'ja'       # 言語（デフォルト: 日本語）
    max = options[:max] || 10                   # 最大取得件数（デフォルト: 10）
    endpoint = options[:endpoint] || '/search'  # エンドポイント（デフォルト: /search）

    response = HTTP.get("#{BASE_URL}#{endpoint}", params: {
      q: topic,
      lang: language,
      max: max,
      token: @api_key
    })

    handle_response(response)
  rescue StandardError => e
    Rails.logger.error "GNews API Error: #{e.message}"
    []
  end

  # 日本経済ニュース専用の簡易メソッド
  def fetch_japanese_economy_news
    fetch_news('日本経済', language: 'ja', max: 10)
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
