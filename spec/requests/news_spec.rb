require 'rails_helper'

RSpec.describe "News", type: :request do
  let(:user) { create(:user) }
  let(:mock_news_service) { instance_double(Api::GNewsService) }
  let(:mock_news_data) do
    [ {
      "title" => "記事タイトル",
      "description" => "記事内容",
      "url" => "https://example.com/news1",
      "image" => "https://example.com/image1.jpg",
      "publishedAt" => "2025-12-27T10:00:00Z",
      "source" => { "name" => "経済新聞" }
    } ]
  end

  before do
    sign_in user
    allow(Api::GNewsService).to receive(:new).and_return(mock_news_service)
  end

  describe "GET /news" do
    context "ニュース取得が成功する場合" do
      before do
        allow(mock_news_service).to receive(:call).and_return(mock_news_data)
      end

      it "正常なレスポンスを返し、ニュースデータが表示されている" do
        get news_index_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("記事タイトル")
        expect(response.body).to include("経済新聞")
      end
    end

    context "ニュース取得が失敗する場合" do
      before do
        allow(mock_news_service).to receive(:call).and_raise(StandardError.new("API Error"))
      end

      it "ログ出力し、メッセージ表示する" do
        expect(Rails.logger).to receive(:error).with(/Failed to fetch news: API Error/)

        get news_index_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(I18n.t("common.actions.get_failed", data: "ニュース"))
      end
    end
  end
end
