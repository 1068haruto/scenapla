require 'rails_helper'

RSpec.describe AssetLifespan, type: :model do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let(:asset_lifespan) { create(:asset_lifespan, user: user, simulation: simulation) }

  describe 'アソシエーションテスト' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe 'バリデーションテスト' do
    it { is_expected.to validate_presence_of(:yearly_lifespans) }
  end

  describe 'クラスメソッドテスト' do
    describe '.update_lifespan_data!' do
      let(:yearly_lifespan) { { "2000" => 20, "2001" => -20 } }
      let(:lifespan_years) { 2 }
      let(:lifespan_months) { 1 }

      context 'asset_lifespanデータがある場合' do
        before do
          asset_lifespan
        end

        it '既存asset_lifespanデータを更新する' do
          expect do
            described_class.update_lifespan_data!(simulation, yearly_lifespan, lifespan_years, lifespan_months)
            asset_lifespan.reload
          end.to change { asset_lifespan.yearly_lifespans }.from({ "2000" => 10, "2001" => -10 }).to({ "2000" => 20, "2001" => -20 })
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
          expect(new_lifespan.yearly_lifespans).to eq({ "2000" => 20, "2001" => -20 })
          expect(new_lifespan.lifespan_years).to eq(2)
          expect(new_lifespan.lifespan_months).to eq(1)
        end
      end
    end
  end
end
