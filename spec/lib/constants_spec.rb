require 'rails_helper'

RSpec.describe Constants do
  describe 'Constants' do
    # time
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
  end
end
