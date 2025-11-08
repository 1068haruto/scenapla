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
      expect(Constants::PAYMENT_PERIOD_OPTIONS).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    end
  end
end