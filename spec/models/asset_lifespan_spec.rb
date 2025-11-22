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
    describe '.update_lifespan_data!' do
      let(:yearly_lifespan) { { "2000" => 20, "2001" => -20 } }
      let(:lifespan_years) { 2 }
      let(:lifespan_months) { 1 }

      context 'asset_lifespanデータがある場合' do
        let!(:asset_lifespan) { create(:asset_lifespan, user: user, simulation: simulation) }

        it '既存asset_lifespanデータを更新する' do
          expect do
            described_class.update_lifespan_data!(simulation, yearly_lifespan, lifespan_years, lifespan_months)
            asset_lifespan.reload
          end.to change { asset_lifespan.asset_lifespan_scenario }
            .from({ "2000" => 10, "2001" => -10 }).to({ "2000" => 20, "2001" => -20 })
            .and change { asset_lifespan.lifespan_years }.to(2)
            .and change { asset_lifespan.lifespan_months }.to(1)
        end
      end

      context 'asset_lifespanデータがない場合' do
        it 'asset_lifespanデータを作成する' do
          expect do
            described_class.update_lifespan_data!(simulation, yearly_lifespan, lifespan_years, lifespan_months)
          end.to change { described_class.count }.by(1)

          new_lifespan = described_class.last
          expect(new_lifespan.asset_lifespan_scenario).to eq({ "2000" => 20, "2001" => -20 })
          expect(new_lifespan.lifespan_years).to eq(2)
          expect(new_lifespan.lifespan_months).to eq(1)
        end
      end
    end
  end
end
