require 'rails_helper'

RSpec.describe DataGenerator::LifeEventDataGenerator, type: :service do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }

  describe '#call' do
    let(:current_year) { Date.current.year }

    context '現実イベントのみ存在する場合' do
      before do
        create(:life_event, user: user, simulation: simulation) # 現実：今年、-1、1年間
      end

      it 'real_event_dataを生成、ideal_event_dataはnilとなる' do
        result = described_class.new(user).call

        expect(result[:real_event_data]).to include({ "date" => current_year, "amount" => -1.0 })
        expect(result[:real_event_data].length).to eq(1)
        expect(result[:ideal_event_data]).to be_nil
      end
    end

    context '現実と理想イベントが存在する場合' do
      before do
        create(:life_event, user: user, simulation: simulation)         # 現実：今年、-1、1年間
        create(:life_event, :ideal, user: user, simulation: simulation) # 理想：(今年+3)年、-3、3年間
      end

      it 'real_event_data、ideal_event_dataを生成する' do
        result = described_class.new(user).call

        expect(result[:real_event_data]).to contain_exactly({ "date" => current_year, "amount" => -1.0 })
        expect(result[:real_event_data].length).to eq(1)
        expected_ideal = [
          { "date" => current_year, "amount" => -1.0 },     # 現実
          { "date" => current_year + 3, "amount" => -3.0 }, # 理想 1年目
          { "date" => current_year + 4, "amount" => -3.0 }, # 理想 2年目
          { "date" => current_year + 5, "amount" => -3.0 }  # 理想 3年目
        ]
        expect(result[:ideal_event_data]).to contain_exactly(*expected_ideal)
        expect(result[:ideal_event_data].length).to eq(4)
      end
    end
  end
end
