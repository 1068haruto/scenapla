class NewsController < AfterBaseController
  def index
    @news = Api::GNewsService.new.call(
      G_NEWS_DEFAULT_TOPIC,
      language: G_NEWS_DEFAULT_LANG,
      max: G_NEWS_DEFAULT_MAX
    )
  rescue => e
    Rails.logger.error("Failed to fetch news: #{e.message}")
    flash.now[:alert] = t("common.actions.get_failed", data: NEWS)
    @news = []
  end
end
