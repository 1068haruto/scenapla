module Constants

  # time
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
end