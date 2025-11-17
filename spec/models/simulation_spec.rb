require 'rails_helper'

RSpec.describe Simulation, type: :model do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }

  describe 'relation' do
    it { should belong_to(:user) }
    it { should have_many(:incomes).dependent(:destroy) }
    it { should have_many(:expenses).dependent(:destroy) }
    it { should have_many(:user_assets).dependent(:destroy) }
    it { should have_many(:life_events).dependent(:destroy) }
    it { should have_many(:scenarios).dependent(:destroy) }
    it { should have_many(:asset_lifespans).dependent(:destroy) }
  end

  describe 'validation' do
    context '必須項目' do
      it 'user_idなしは、無効' do
        simulation.user_id = nil
        expect(simulation).not_to be_valid
      end
    end
  end

  describe 'method' do
    describe '#user_asset_chart_data' do
      before do
        allow(simulation).to receive(:user_asset_data).and_return([
          { 'date' => '2000', 'amount' => 200 }, { 'date' => '2001', 'amount' => 100 }
        ])
      end

      it 'Chartkick用にフォーマットする' do
        expected_result = { '2000' => 200, '2001' => 100 }
        expect(simulation.user_asset_chart_data).to eq(expected_result)
      end
    end
  end
end
