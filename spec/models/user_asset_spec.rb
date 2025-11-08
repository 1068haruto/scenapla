require 'rails_helper'

RSpec.describe UserAsset, type: :model do
  let(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let!(:user_asset) { create(:user_asset, user: user, simulation: simulation) }

  describe 'Relation' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe 'Enum' do
    it 'person_typeが正しい値を持つ' do
      expect(described_class.person_types).to eq({ "本人" => 0, "配偶者" => 1 })
    end

    it 'asset_typeが正しい値を持つ' do
      expect(described_class.asset_types).to eq({
        "預金" => 0, "貯蓄型保険" => 1, "投資_NISA" => 2, "投資_iDeCo" => 3, "投資_その他" => 4
      })
    end
  end

  describe 'Validation' do
    context '必須項目' do
      it 'user_idなしは、無効' do
        user_asset.user_id = nil
        expect(user_asset).not_to be_valid
      end

      it 'simulation_idなしは、無効' do
        user_asset.simulation_id = nil
        expect(user_asset).not_to be_valid
      end

      it '対象者なしは、無効' do
        user_asset.person_type = nil
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:person_type]).to include("対象者を入力してください。")
      end

      it '資産種類なしは、無効' do
        user_asset.asset_type = nil
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:asset_type]).to include("資産種類を入力してください。")
      end

      it '総額なしは、無効' do
        user_asset.amount = nil
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:amount]).to include("総額を入力してください。")
      end

      it '利回りなしは、無効' do
        user_asset.return_rate = nil
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:return_rate]).to include("利回りを入力してください。")
      end
    end

    context 'プラス値項目' do
      it '総額がマイナスなら無効' do
        user_asset.amount = -1
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:amount]).to include("総額はプラス値で入力してください。")
      end

      it '利回りがマイナスなら無効' do
        user_asset.return_rate = -1
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:return_rate]).to include("利回りはプラス値で入力してください。")
      end
    end

    context '数値項目' do
      it '総額がInt以外なら無効' do
        user_asset.amount = 'abc'
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:amount]).to include("数値を入力してください。")
      end

      it '利回りがInt以外なら無効' do
        user_asset.return_rate = 'abc'
        expect(user_asset).not_to be_valid
        expect(user_asset.errors[:return_rate]).to include("数値を入力してください。")
      end
    end
  end

  describe 'method' do
    describe '.generateUserAssetData' do
      it 'user_asset_dataを生成する' do
        currentYear = Date.today.year
        yearAtSeventy = currentYear + 10

        result = UserAsset.generateUserAssetData(user)

        expect(result.first).to include({ date: currentYear, amount: 100 })
        expect(result.last).to include({ date: yearAtSeventy, amount: 215.3 })
        expect(result.length).to eq(11)
      end
    end
  end
end
