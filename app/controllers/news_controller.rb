class NewsController <  ApplicationController
  include Constants

  before_action :authenticate_user!

  def index
    @news = Api::GNewsService.new.call(
      topic: G_NEWS_DEFAULT_TOPIC,
      language: G_NEWS_DEFAULT_LANG,
      max: G_NEWS_DEFAULT_MAX
    )
  rescue => e
    flash.now[:alert] = "ニュースを取得できません: #{e.message}"
    @news = []
  end
end
