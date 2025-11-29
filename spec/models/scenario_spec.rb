require 'rails_helper'

RSpec.describe Scenario, type: :model do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }
  let(:scenario) { create(:scenario, user: user, simulation: simulation) }

  describe 'Relation' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe 'Validation' do
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
end
