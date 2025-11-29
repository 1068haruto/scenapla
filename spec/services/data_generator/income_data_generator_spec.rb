require 'rails_helper'

RSpec.describe DataGenerator::IncomeDataGenerator, type: :service do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }

  describe '#call' do
    let(:current_year) { Date.current.year }

    before do
      create(:income, user: user, simulation: simulation)
      create(:income, user: user, simulation: simulation)
    end

    it '収入データを生成する' do
      result = described_class.new(user).call

      expect(result).to include(
        { "amount" => 26.0, "date" => current_year },
        { "amount" => 26.0, "date" => current_year + 1 },
        { "amount" => 26.0, "date" => current_year + 2 },
        { "amount" => 26.0, "date" => current_year + 3 },
        { "amount" => 26.0, "date" => current_year + 4 },
        { "amount" => 28.0, "date" => current_year + 5 } # 退職金あり
      )
      expect(result.length).to eq(6) # 6年間
    end
  end
end
