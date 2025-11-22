require 'rails_helper'

RSpec.describe AssetLifespan, type: :model do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let(:asset_lifespan) { build(:asset_lifespan, user: user, simulation: simulation) }

  describe 'relation' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe 'validation' do
    context '必須項目' do
      it 'user_idなしは、無効' do
        asset_lifespan.user_id = nil
        expect(asset_lifespan).not_to be_valid
      end

      it 'simulation_idなしは、無効' do
        asset_lifespan.simulation_id = nil
        expect(asset_lifespan).not_to be_valid
      end

      it 'asset_lifespan_scenarioなしは、無効' do
        asset_lifespan.asset_lifespan_scenario = nil
        expect(asset_lifespan).not_to be_valid
      end

      it 'lifespan_yearsなしは、無効' do
        asset_lifespan.lifespan_years = nil
        expect(asset_lifespan).not_to be_valid
      end

      it 'lifespan_monthsなしは、無効' do
        asset_lifespan.lifespan_months = nil
        expect(asset_lifespan).not_to be_valid
      end
    end

    context 'プラス値項目' do
      it 'lifespan_yearsがマイナスなら無効' do
        asset_lifespan.lifespan_years = -1
        expect(asset_lifespan).not_to be_valid
      end

      it 'lifespan_monthsがマイナスなら無効' do
        asset_lifespan.lifespan_months = -1
        expect(asset_lifespan).not_to be_valid
      end
    end

    context '数値項目' do
      it "lifespan_yearsがInt以外なら無効" do
        asset_lifespan.lifespan_years = "abc"
        expect(asset_lifespan).not_to be_valid
      end

      it "lifespan_yearsがInt以外なら無効" do
        asset_lifespan.lifespan_months = "abc"
        expect(asset_lifespan).not_to be_valid
      end
    end
  end

  describe 'method' do
    pending "ロジック確定後、実装"
  end
end
