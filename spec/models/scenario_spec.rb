require 'rails_helper'

RSpec.describe Scenario, type: :model do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }
  let(:scenario) { create(:scenario, user: user, simulation: simulation, scenario_type: "現実") }

  describe 'アソシエーションテスト' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe 'enumテスト' do
    it 'scenario_typeが正しい値を持つ' do
      expect(described_class.scenario_types).to eq({ '現実' => 0, '理想' => 1 })
    end
  end

  describe 'バリデーションテスト' do
    context '必須項目の確認' do
      it 'user_idは必須' do
        scenario.user_id = nil
        expect(scenario).not_to be_valid
      end

      it 'simulation_idは必須' do
        scenario.simulation_id = nil
        expect(scenario).not_to be_valid
      end
    end
  end

  describe 'インスタンスメソッドテスト' do
    describe '#balance_chart_data' do
      before do
        allow(scenario).to receive(:balance_scenario).and_return([
          { 'date' => '2000', 'amount' => 200 }, { 'date' => '2001', 'amount' => 100 }
        ])
      end

      it 'Chartkick用にフォーマットする' do
        expected_result = { '2000' => 200, '2001' => 100 }
        expect(scenario.balance_chart_data).to eq(expected_result)
      end
    end

    describe '#update_scenario_data!' do
      before do
        allow(simulation).to receive(:real_event_data).and_return('real_data')
        allow(simulation).to receive(:ideal_event_data).and_return('ideal_data')
        allow(Simulation).to receive(:generate_scenario_data).with(simulation, 'real_data').and_return({ result: 'updated_real_data' })
        allow(Simulation).to receive(:generate_scenario_data).with(simulation, 'ideal_data').and_return({ result: 'updated_ideal_data' })
      end

      it '現実のシナリオデータ更新処理が呼ばれる' do
        scenario.update(scenario_type: '現実')
        expect(scenario).to receive(:update!).with({ result: 'updated_real_data' })
        scenario.update_scenario_data!
      end

      it '理想のシナリオデータ更新処理が呼ばれる' do
        scenario.update(scenario_type: '理想')
        expect(scenario).to receive(:update!).with({ result: 'updated_ideal_data' })
        scenario.update_scenario_data!
      end
    end
  end
end
