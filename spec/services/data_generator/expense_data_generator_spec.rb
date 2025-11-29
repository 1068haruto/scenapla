require 'rails_helper'

RSpec.describe DataGenerator::ExpenseDataGenerator, type: :service do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }

  describe '#call' do
    let(:current_year) { Date.today.year }
    let(:year_after_repayment) { current_year + 4 }
    let(:year_at_seventy) { current_year + 10 }

    before do
      create(:expense, user: user, simulation: simulation)
    end

    it 'ローン有無を考慮した支出データを生成する' do
      result = described_class.new(user).call

      expect(result.first).to include({ date: current_year, amount: -48 })
      expect(result).to include({ date: year_after_repayment, amount: -36 })
      expect(result.last).to include({ date: year_at_seventy, amount: -36 })
      expect(result.length).to eq(11)
    end
  end
end
