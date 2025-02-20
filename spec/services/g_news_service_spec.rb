require "rails_helper"

RSpec.describe GNewsService do
  let(:http_client) { instance_double(HTTP::Client) }
  let(:service) { described_class.new(http_client: http_client) }
  let(:topic) { "経済" }
  let(:language) { "ja" }
  let(:max) { 10 }
  let(:endpoint) { "/search" }
  let(:cache_key) { "gnews#{endpoint}/#{topic}/#{language}/#{max}" }
  let(:api_key) { "test_api_key" }
  let(:response_body) { { "articles" => [ { "title" => "テスト記事" } ] }.to_json }

  before do
    allow(ENV).to receive(:[]).with("GNEWS_API_KEY").and_return(api_key)
    allow(Rails.application.credentials).to receive(:dig).with(:gnews, :api_key).and_return(nil)
    allow(Rails.cache).to receive(:fetch).and_call_original
  end

  describe "#fetch_news" do
    context "APIリクエストが成功した場合" do
      let(:response) { instance_double(HTTP::Response, status: double(success?: true), body: response_body) }

      before do
        allow(http_client).to receive(:get).and_return(response)
        allow(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 24.hours).and_yield
      end

      it "APIリクエストを実行し、結果を返す" do
        result = service.fetch_news(topic)
        expect(result).to eq([ { "title" => "テスト記事" } ])
        expect(http_client).to have_received(:get).with(
          "https://gnews.io/api/v4/search",
          params: { q: topic, lang: language, max: max, token: api_key }
        )
      end
    end

    context "APIリクエストが失敗した場合" do
      let(:response) { instance_double(HTTP::Response, status: double(success?: false), body: "エラー") }

      before do
        allow(http_client).to receive(:get).and_return(response)
        allow(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 24.hours).and_yield
      end

      it "空の配列を返す" do
        result = service.fetch_news(topic)
        expect(result).to eq([])
      end
    end

    context "キャッシュが有効な場合" do
      let(:cached_result) { [ { "title" => "キャッシュされた記事" } ] }

      before do
        allow(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 24.hours).and_return(cached_result)
        allow(http_client).to receive(:get)
      end

      it "キャッシュされたデータを返す" do
        result = service.fetch_news(topic)
        expect(result).to eq(cached_result)
        expect(http_client).not_to have_received(:get)
      end
    end

    context "エラーが発生した場合" do
      before do
        allow(http_client).to receive(:get).and_raise(StandardError.new("API接続エラー"))
        allow(Rails.logger).to receive(:error)
      end

      it "エラーハンドリングが行われ、空の配列を返す" do
        result = service.fetch_news(topic)
        expect(result).to eq([])
        expect(Rails.logger).to have_received(:error).with("GNews API Error: API接続エラー")
      end
    end
  end
end
