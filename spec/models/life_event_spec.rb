require 'rails_helper'

RSpec.describe LifeEvent, type: :model do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }

  describe 'Relation' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe 'Enum' do
    it 'event_typeが正しい値を持つ' do
      expect(described_class.event_types).to eq({ "現実" => 0, "理想" => 1 })
    end
  end

  describe 'Validation' do
    let(:life_event) { build(:life_event) }

    context '必須項目' do
      it 'user_idなしは、無効' do
        life_event.user_id = nil
        expect(life_event).not_to be_valid
      end

      it 'simulation_idなしは、無効' do
        life_event.simulation_id = nil
        expect(life_event).not_to be_valid
      end

      it 'イベントタイプなしは、無効' do
        life_event.event_type = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:event_type]).to include("イベントタイプを入力してください。")
      end

      it '時期なしは、無効' do
        life_event.event_date = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:event_date]).to include("時期を入力してください。")
      end

      it 'タイトルなしは、無効' do
        life_event.title = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:title]).to include("タイトルを入力してください。")
      end

      it '年額なしは、無効' do
        life_event.amount = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:amount]).to include("年額を入力してください。")
      end

      it '支払期間なしは、無効' do
        life_event.payment_period = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:payment_period]).to include("支払期間を入力してください。")
      end
    end

    context 'プラス値項目' do
      it '年額がマイナスなら無効' do
        life_event.amount = -1
        expect(life_event).not_to be_valid
        expect(life_event.errors[:amount]).to include("年額はプラス値で入力してください。")
      end
    end

    context '数値項目' do
      it '年額がInt以外なら無効' do
        life_event.amount = 'abc'
        expect(life_event).not_to be_valid
        expect(life_event.errors[:amount]).to include("数値を入力してください。")
      end
    end
  end

  describe "Method" do
    describe ".generate_life_event_data" do
      year = Date.current.year

      context '現実イベントのみ存在する場合' do
        it 'real_event_dataを生成、ideal_event_dataはnilとなる' do
          create(:life_event, user: user, simulation: simulation) # 現実:今年、-1、1年間

          result = LifeEvent.generate_life_event_data(user)

          expect(result[:real_event_data]).to include({ date: year, amount: -1.0 })
          expect(result[:real_event_data].length).to eq(1)
          expect(result[:ideal_event_data]).to be_nil
        end
      end

      context '現実と理想イベントが存在する場合' do
        it 'real_event_data、ideal_event_dataを生成する' do
          create(:life_event, user: user, simulation: simulation)         # 現実:今年、-1、1年間
          create(:life_event, :ideal, user: user, simulation: simulation) # 理想:(今年+3)年、-3、3年間

          result = LifeEvent.generate_life_event_data(user)

          expect(result[:real_event_data]).to contain_exactly({ date: year, amount: -1.0 })
          expect(result[:real_event_data].length).to eq(1)
          expected_ideal_data = [
            { date: year, amount: -1.0 },     # 現実イベント
            { date: year + 3, amount: -3.0 }, # 理想イベント 1年目
            { date: year + 4, amount: -3.0 }, # 理想イベント 2年目
            { date: year + 5, amount: -3.0 }  # 理想イベント 3年目
          ]
          expect(result[:ideal_event_data]).to contain_exactly(*expected_ideal_data)
          expect(result[:ideal_event_data].length).to eq(4)
        end
      end
    end
  end
end
