module Constants
  # Time（common）
  MONTHS_IN_A_YEAR = 12
  JANUARY = 1
  FIRST = 1

  # User
  AGE_LIMIT = 70

  # Expense
  NO_REPAYMENT_YEAR = 0

  # UserAsset
  TAX_RATE = 0.20315  # 20.315％（所得税等15.315％、住民税５％）
  ASSET_TYPE_IS_OTHER = "投資_その他"

  # LifeEvent
  PAYMENT_PERIOD_OPTIONS = (1..10).to_a

  # AssetLifespan
  MONTH_OFFSET_FOR_INCLUSION = 1

  # News
  G_NEWS_BASE_URL = "https://gnews.io/api/v4"
  G_NEWS_DEFAULT_TOPIC = "経済"                # 記事種類（経済）
  G_NEWS_DEFAULT_LANG = "ja"                  # 表示言語（日本語）
  G_NEWS_DEFAULT_MAX = 10                     # 最大取得件数（10件）無料では10がmax
  G_NEWS_DEFAULT_ENDPOINT = "/search"         # エンドポイント（/search）
  G_NEWS_CACHE_EXPIRATION = 24.hours          # キャッシュの有効期限（24時間）
end
