require 'rails_helper'

RSpec.describe DataGenerator::UserAssetDataGenerator, type: :service do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }

  describe '#call' do
    let(:current_year) { Date.today.year }
    let(:year_at_seventy) { current_year + 10 }

    before do
      create(:user_asset, user: user, simulation: simulation)
    end

    it '資産データを生成する' do
      result = described_class.new(user).call

      expect(result.first).to include({ "date" => current_year, "amount" => 100.0 })
      expect(result.last).to include({ "date" => year_at_seventy, "amount" => 215.3 })
      expect(result.length).to eq(11)
    end
  end
end
