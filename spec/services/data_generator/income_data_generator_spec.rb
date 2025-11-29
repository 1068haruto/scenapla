require 'rails_helper'

RSpec.describe DataGenerator::IncomeDataGenerator, type: :service do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }
  let(:current_year) { Date.current.year }

  describe '#call' do
    let(:generator) { described_class.new(user) }

    before do
      create(:income, user: user, simulation: simulation)
      create(:income, user: user, simulation: simulation)
    end

    it 'ユーザーの全収入データを集計して年度別データ（Array）を生成する' do
      result = generator.call

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
