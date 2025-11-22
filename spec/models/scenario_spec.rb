require 'rails_helper'

RSpec.describe Scenario, type: :model do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }
  let(:scenario) { create(:scenario, user: user, simulation: simulation, scenario_type: "現実") }

  describe 'relation' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe 'enum' do
    it 'scenario_typeが正しい値を持つ' do
      expect(described_class.scenario_types).to eq({ '現実' => 0, '理想' => 1 })
    end
  end

  describe 'validation' do
    context '必須項目' do
      it 'user_idなしは、無効' do
        scenario.user_id = nil
        expect(scenario).not_to be_valid
      end

      it 'simulation_idなしは、無効' do
        scenario.simulation_id = nil
        expect(scenario).not_to be_valid
      end
    end
  end

  describe 'method' do
    pending "ロジック確定後、実装"
  end
end
