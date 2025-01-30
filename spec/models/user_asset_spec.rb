require 'rails_helper'

RSpec.describe UserAsset, type: :model do
  let(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let!(:user_asset) { create(:user_asset, user: user, simulation: simulation) }

  describe 'アソシエーションテスト' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe '定数テスト' do
    it 'AGE_LIMITは70である' do
      expect(described_class::AGE_LIMIT).to eq(70)
    end

    it 'TAX_RATEは12である' do
      expect(described_class::TAX_RATE).to eq(0.2)
    end

    it 'ASSET_TYPE_IS_OTHERは12である' do
      expect(described_class::ASSET_TYPE_IS_OTHER).to eq("投資_その他")
    end
  end

  describe 'enumテスト' do
    it 'person_typeが正しい値を持つ' do
      expect(described_class.person_types).to eq({ "本人" => 0, "配偶者" => 1 })
    end

    it 'asset_typeが正しい値を持つ' do
      expect(described_class.asset_types).to eq({ "預金" => 0, "貯蓄型保険" => 1, "投資_NISA" => 2, "投資_iDeCo" => 3, "投資_その他" => 4 })
    end
  end

  describe 'バリデーションテスト' do
    context '必須項目の確認' do
      it { is_expected.to validate_presence_of(:user_id) }
      it { is_expected.to validate_presence_of(:simulation_id) }

      it '対象者は必須' do
        user_asset.person_type = nil
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:person_type]).to include("対象者を選択してください。")
      end

      it '資産種類は必須' do
        user_asset.asset_type = nil
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:asset_type]).to include("資産種類を選択してください。")
      end

      it '総額は必須' do
        user_asset.amount = nil
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:amount]).to include("総額を入力してください。")
      end

      it '利回りは必須' do
        user_asset.return_rate = nil
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:return_rate]).to include("利回りを入力してください。")
      end
    end

    context 'プラス値入力の確認' do
      it '総額が0以上' do
        user_asset.amount = -1
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:amount]).to include("総額はプラス値で入力してください。")
      end

      it '利回りが0以上' do
        user_asset.return_rate = -1
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:return_rate]).to include("利回りはプラス値で入力してください。")
      end
    end

    context '数値入力の確認' do
      it '総額が数値である' do
        user_asset.amount = 'abc'
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:amount]).to include("数値を入力して下さい。")
      end

      it '利回りが数値である' do
        user_asset.return_rate = 'abc'
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:return_rate]).to include("数値を入力して下さい。")
      end
    end
  end

  describe 'クラスメソッドテスト' do
    describe '.generate_user_asset_data_for' do
      let!(:user) { create(:user, date_of_birth: Date.new(2000, 1, 1)) }
      let!(:user_assets) { create_list(:user_asset, 3, user: user, simulation: simulation) }
      let(:year_at_seventy) { user.date_of_birth.year + 6.years }
      let(:yearly_totals) { { 2025 => 1000, 2026 => 1100 } }
      let(:formatted_totals) { [ { date: 2025, amount: 1000.0 }, { date: 2026, amount: 1100.0 } ] }

      before do
        allow(described_class).to receive(:where).with(user: user).and_return(user_assets)
        allow(described_class).to receive(:get_year_when_seventy).with(user).and_return(year_at_seventy)
        allow(described_class).to receive(:initialize_yearly_totals).with(user_assets, year_at_seventy).and_return(yearly_totals)
        allow(described_class).to receive(:format_yearly_totals).with(yearly_totals).and_return(formatted_totals)
      end

      it 'whereメソッドが正しく引数を取り呼ばれる' do
        expect(described_class).to receive(:where).with(user: user)
        described_class.generate_user_asset_data_for(user)
      end

      it 'get_year_when_seventyメソッドが正しく引数を取り呼ばれる' do
        expect(described_class).to receive(:get_year_when_seventy).with(user)
        described_class.generate_user_asset_data_for(user)
      end

      it 'initialize_yearly_totalsメソッドが正しく引数を取り呼ばれる' do
        expect(described_class).to receive(:initialize_yearly_totals).with(user_assets, year_at_seventy)
        described_class.generate_user_asset_data_for(user)
      end

      it 'format_yearly_totalsメソッドが正しく引数を取り呼ばれる' do
        expect(described_class).to receive(:format_yearly_totals).with(yearly_totals)
        described_class.generate_user_asset_data_for(user)
      end

      it '最終的な戻り値が正しい' do
        result = described_class.generate_user_asset_data_for(user)
        expect(result).to eq(formatted_totals)
      end
    end

    describe '.get_year_when_seventy' do
      it 'ユーザーが70歳になる年を正しく計算すること' do
        user_age_seventy = (user.date_of_birth + 70.years).year
        expect(described_class.get_year_when_seventy(user)).to eq(user_age_seventy)
      end
    end

    describe '.initialize_yearly_totals' do
      let(:asset) { double('Asset', amount: 10, return_rate: 10, asset_type: 0) }
      let(:year_at_seventy) { Date.today.year + 30 }

      it '初期化したハッシュを返すこと' do
        allow(described_class).to receive(:calculate_asset_projection)

        result = described_class.initialize_yearly_totals([ asset ], year_at_seventy)
        expect(result).to be_a(Hash)
      end

      it '資産ごとにcalculate_asset_projectionが呼ばれること' do
        expect(described_class).to receive(:calculate_asset_projection).with(asset, anything, anything, anything)

        described_class.initialize_yearly_totals([ asset ], year_at_seventy)
      end
    end

    describe '.calculate_asset_projection' do
      let(:yearly_totals) { Hash.new(0) }
      let(:current_year) { Date.today.year }
      let(:year_at_seventy) { current_year + 30 }
      let(:asset) { double('Asset', amount: 10, return_rate: 10, asset_type: 0) }

      it '1年目の資産額が設定される' do
        allow(described_class).to receive(:calculate_future_years)

        described_class.calculate_asset_projection(asset, yearly_totals, current_year, year_at_seventy)
        expect(yearly_totals[current_year]).to eq(10)
      end

      it 'calculate_future_years が呼び出される' do
        expect(described_class).to receive(:calculate_future_years).with(0, 10, 0.1, yearly_totals, current_year, year_at_seventy)
        described_class.calculate_asset_projection(asset, yearly_totals, current_year, year_at_seventy)
      end
    end

    describe '.calculate_future_years' do
      let(:yearly_totals) { Hash.new(0) }
      let(:current_year) { Date.today.year }
      let(:year_at_seventy) { current_year + 2 }
      let(:amount) { 10 }
      let(:rate) { 0.1 }
      let(:asset_type) { 0 }

      it '2年目以降の各年の資産額を計算しハッシュ配列を返す' do
        described_class.calculate_future_years(asset_type, amount, rate, yearly_totals, current_year, year_at_seventy)
        expect(yearly_totals).to eq({ current_year + 1 => 11, current_year + 2 => 12.1 })
      end
    end

    describe '.calculate_profit' do
      amount = 10

      it '利回りが0の場合、利益は0となる' do
        rate = 0
        asset_type = "預金"
        profit = described_class.calculate_profit(amount, rate, asset_type)
        expect(profit).to eq(0) # 10 * 0
      end

      it '利回りが0以上の場合、利益を正しく計算する（資産種類: 投資_その他以外）' do
        rate = 0.1
        asset_type = "預金"
        profit = described_class.calculate_profit(amount, rate, asset_type)
        expect(profit).to eq(1) # 10 * 0.1
      end

      it '利回りが0以上の場合、利益を正しく計算する（資産種類: 投資_その他）' do
        rate = 0.1
        asset_type = "投資_その他"
        profit = described_class.calculate_profit(amount, rate, asset_type)
        expect(profit).to eq(0.8) # 10 * 0.1 * 0.8
      end
    end

    describe '.format_yearly_totals' do
      let(:yearly_totals) { { 2025 => 10.1234, 2026 => 10.1234 } }

      it '小数第1位までに整形したハッシュ配列を返す' do
        result = described_class.format_yearly_totals(yearly_totals)
        expect(result).to eq([ { date: 2025, amount: 10.1 }, { date: 2026, amount: 10.1 } ])
      end
    end
  end
end
