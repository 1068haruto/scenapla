class NewsController < ApplicationController
  def index
    @news = fetch_news('経済', 'ja', 10)
  rescue StandardError => error
    flash.now[:alert] = "ニュースの取得に失敗しました: #{error.message}"
    @news = []
  end

  private

  # ニュースを取得する共通メソッド
  def fetch_news(topic, language, max)
    GNewsService.new.fetch_news(topic, language: language, max: max)
  end
end
