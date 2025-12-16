module Constants
  # TIME
  MONTHS_IN_A_YEAR = 12
  JANUARY = 1
  FIRST = 1

  # User / LifePlan(vm)
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

  # OpenAI(advice)
  ADVICE_LIMIT_PER_MONTH = 3
  MAX_TOKENS = 300
  TEMPERATURE = 0.7

  # News
  G_NEWS_BASE_URL = "https://gnews.io/api/v4"
  G_NEWS_DEFAULT_TOPIC = "経済"
  G_NEWS_DEFAULT_LANG = "ja"           # 日本語
  G_NEWS_DEFAULT_MAX = 10              # 最大取得件数（無料は10件がmax）
  G_NEWS_DEFAULT_ENDPOINT = "/search"
  G_NEWS_CACHE_EXPIRATION = 24.hours   # キャッシュの有効期限

  # LifePlan(vm)
  DECADE = 10
  TEN_YEARS_OLD = 10

  # NAME
  INCOME_INFO = "収入情報"
  EXPENSE_INFO = "支出情報"
  ASSET_INFO = "資産情報"
  LIFE_EVENT_INFO = "ライフイベント情報"
  SIMULATION_DATA = "シミュレーションデータ"
  SCENARIO = "シナリオ"
  AI_ADVICE = "AIアドバイス"
  MEMO = "メモ"
  NEWS = "ニュース"
  ACCOUNT_INFO = "アカウント情報"
  DATE_OF_BIRTH = "生年月日"
end
