require "http"

class GNewsService
  BASE_URL = "https://gnews.io/api/v4".freeze
  DEFAULT_LANGUAGE = "ja".freeze                # 表示言語（デフォルト: 日本語）
  DEFAULT_MAX = 10.freeze                       # 最大取得件数（デフォルト: 10）※ 無料プランでは10件がmax
  DEFAULT_ENDPOINT = "/search".freeze           # エンドポイント（デフォルト: /search）
  CACHE_EXPIRATION = 24.hours.freeze            # キャッシュの有効期限（24時間）

  def initialize(http_client: HTTP)
    @http_client = http_client
    @api_key = fetch_api_key
  end

  # ニュース取得(キャッシュ対応)
  def fetch_news(topic, options = {})
    language = options[:language] || DEFAULT_LANGUAGE
    max = options[:max] || DEFAULT_MAX
    endpoint = options[:endpoint] || DEFAULT_ENDPOINT

    cache_key = "gnews#{endpoint}/#{topic}/#{language}/#{max}"  # キャッシュキー作成

    result = fetch_from_cache_or_api(cache_key, topic, language, max, endpoint)

    log_cache_status(cache_key)

    result
  rescue StandardError => error
    handle_error(error)
  end

  private

  def fetch_api_key
    key = ENV["GNEWS_API_KEY"] || Rails.application.credentials.dig(:gnews, :api_key)
    raise "GNews API Key is missing. Set it in ENV or credentials." unless key
    key
  end

  # キャッシュがあれば使用、無ければAPIリクエスト
  def fetch_from_cache_or_api(cache_key, topic, language, max, endpoint)
    Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRATION) do
      Rails.logger.info("Cache miss for key: #{cache_key}. Fetching data from API.")
      response = @http_client.get("#{BASE_URL}#{endpoint}", params: request_params(topic, language, max))
      handle_response(response)
    end
  end

  def request_params(topic, language, max)
    {
      q: topic,
      lang: language,
      max: max,
      token: @api_key
    }
  end

  def log_cache_status(cache_key)
    Rails.logger.info("Cache hit for key: #{cache_key}. Returning cached data.") if Rails.cache.exist?(cache_key)
  end

  # レスポンスのエラーハンドリング
  def handle_response(response)
    if response.status.success?
      JSON.parse(response.body.to_s)["articles"]
    else
      Rails.logger.error "GNews API Response Error: #{response.status} - #{response.body}"
      []
    end
  end

  def handle_error(error)
    Rails.logger.error "GNews API Error: #{error.message}"
    []
  end
end
