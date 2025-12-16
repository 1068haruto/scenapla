require 'rails_helper'

RSpec.describe Constants do
  describe 'Constants' do
    # TIME
    it 'MONTHS_IN_A_YEARは「12」' do
      expect(Constants::MONTHS_IN_A_YEAR).to eq(12)
    end

    it 'JANUARYは「1」' do
      expect(described_class::JANUARY).to eq(1)
    end

    it 'FIRSTは「1」' do
      expect(described_class::FIRST).to eq(1)
    end

    # User
    it 'AGE_LIMITは「70」' do
      expect(Constants::AGE_LIMIT).to eq(70)
    end

    # Expense
    it 'NO_REPAYMENT_YEARは「0」' do
      expect(described_class::NO_REPAYMENT_YEAR).to eq(0)
    end

    # UserAsset
    it 'TAX_RATEは「0.20315」' do
      # 浮動小数点数の為 be_within
      expect(Constants::TAX_RATE).to be_within(0.00001).of(0.20315)
    end

    it 'ASSET_TYPE_IS_OTHERは「12」' do
      expect(Constants::ASSET_TYPE_IS_OTHER).to eq("投資_その他")
    end

    # LifeEvent
    it 'PAYMENT_PERIOD_OPTIONSは「正しい範囲の配列」' do
      expect(Constants::PAYMENT_PERIOD_OPTIONS).to eq([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
    end

    # AssetLifespan
    it 'MONTH_OFFSET_FOR_INCLUSIONは「1」' do
      expect(Constants::MONTH_OFFSET_FOR_INCLUSION).to eq(1)
    end

    # OpenaiService（advice）
    it 'ADVICE_LIMIT_PER_MONTHは「3」' do
      expect(Constants::ADVICE_LIMIT_PER_MONTH).to eq(3)
    end

    it 'MAX_TOKENSは「300」' do
      expect(Constants::MAX_TOKENS).to eq(300)
    end

    it 'TEMPERATUREは「0.7」' do
      expect(Constants::TEMPERATURE).to be_within(0.0001).of(0.7)
    end

    # GNewsService（news）
    it 'G_NEWS_BASE_URLは「"https://gnews.io/api/v4"」' do
      expect(Constants::G_NEWS_BASE_URL).to eq("https://gnews.io/api/v4")
    end

    it 'G_NEWS_DEFAULT_TOPICは「経済」' do
      expect(Constants::G_NEWS_DEFAULT_TOPIC).to eq("経済")
    end

    it 'G_NEWS_DEFAULT_LANGは「ja」' do
      expect(Constants::G_NEWS_DEFAULT_LANG).to eq("ja")
    end

    it 'G_NEWS_DEFAULT_MAXは「10」' do
      expect(Constants::G_NEWS_DEFAULT_MAX).to eq(10)
    end

    it 'G_NEWS_DEFAULT_ENDPOINTは「/search」' do
      expect(Constants::G_NEWS_DEFAULT_ENDPOINT).to eq("/search")
    end

    it 'G_NEWS_CACHE_EXPIRATIONは「24.hours」' do
      expect(Constants::G_NEWS_CACHE_EXPIRATION).to eq(24.hours)
    end

    # LifePlan(vm)
    it 'DECADEは「10」' do
      expect(Constants::DECADE).to eq(10)
    end

    it 'TEN_YEARS_OLDは「10」' do
      expect(Constants::TEN_YEARS_OLD).to eq(10)
    end

    # NAME
    it 'INCOME_INFOは「収入情報」' do
      expect(Constants::INCOME_INFO).to eq("収入情報")
    end

    it 'EXPENSE_INFOは「支出情報」' do
      expect(Constants::EXPENSE_INFO).to eq("支出情報")
    end

    it 'ASSET_INFOは「資産情報」' do
      expect(Constants::ASSET_INFO).to eq("資産情報")
    end

    it 'LIFE_EVENT_INFOは「ライフイベント情報」' do
      expect(Constants::LIFE_EVENT_INFO).to eq("ライフイベント情報")
    end

    it 'SIMULATION_DATAは「シミュレーションデータ」' do
      expect(Constants::SIMULATION_DATA).to eq("シミュレーションデータ")
    end

    it 'SCENARIOは「シナリオ」' do
      expect(Constants::SCENARIO).to eq("シナリオ")
    end

    it 'AI_ADVICEは「AIアドバイス」' do
      expect(Constants::AI_ADVICE).to eq("AIアドバイス")
    end

    it 'MEMOは「メモ」' do
      expect(Constants::MEMO).to eq("メモ")
    end

    it 'NEWSは「ニュース」' do
      expect(Constants::NEWS).to eq("ニュース")
    end

    it 'ACCOUNT_INFOは「アカウント情報」' do
      expect(Constants::ACCOUNT_INFO).to eq("アカウント情報")
    end

    it 'DATE_OF_BIRTHは「生年月日」' do
      expect(Constants::DATE_OF_BIRTH).to eq("生年月日")
    end
  end
end
