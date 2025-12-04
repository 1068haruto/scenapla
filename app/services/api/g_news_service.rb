require "http"

module Api
  class GNewsService
    include Constants

    def initialize(http_client: HTTP)
      @http_client = http_client
      @api_key = get_api_key!
    end

    # ニュース取得-> Array
    def call(topic, options = {})
      opts = build_options(options)
      cache_key = "gnews#{opts[:endpoint]}/#{topic}/#{opts[:language]}/#{opts[:max]}"

      result = fetch_news_data(cache_key, topic, opts)
      result
    rescue => e
      Rails.logger.error("fetch news error: #{e.message}")
      []
    end

    private

    def get_api_key!
      api_key = ENV["GNEWS_API_KEY"] || Rails.application.credentials.dig(:gnews, :api_key)
      raise "API key not found." unless api_key
      api_key
    end

    # Cache or APIから取得し、Cacheに保存-> Array
    def fetch_news_data(cache_key, topic, opts)
      Rails.cache.fetch(cache_key, expires_in: G_NEWS_CACHE_EXPIRATION) do
        Rails.logger.info("Cache miss. Fetch from API.")

        res = @http_client.get(
          "#{G_NEWS_BASE_URL}#{opts[:endpoint]}",
          params: request_params(topic, opts)
        )

        if res.status.success?
          JSON.parse(res.body.to_s)["articles"]
        else
          Rails.logger.error "Response error: #{res.status} - #{res.body}"
          []
        end
      end
    end

    # オプション設定-> Hash
    def build_options(options)
      {
        language: options[:language] || G_NEWS_DEFAULT_LANG,
        max: options[:max] || G_NEWS_DEFAULT_MAX,
        endpoint: options[:endpoint] || G_NEWS_DEFAULT_ENDPOINT
      }
    end

    # APIリクエスト用パラメータ-> Hash
    def request_params(topic, opts)
      {
        q: topic,
        lang: opts[:language],
        max: opts[:max],
        token: @api_key
      }
    end
  end
end
