require 'rails_helper'

RSpec.describe LifeEvent, type: :model do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let!(:real_event1) do
    create(:life_event,
      user: user, user: user, simulation: simulation,
      event_type: "現実", event_date: Date.new(2025, 1, 1), amount: 10, payment_span: 2
    )
  end
  let!(:real_event2) do
    create(:life_event,
      user: user, user: user, simulation: simulation,
      event_type: "現実", event_date: Date.new(2026, 1, 1), amount: 20, payment_span: 1
    )
  end
  let!(:ideal_event1) do
    create(:life_event,
      user: user, user: user, simulation: simulation,
      event_type: "理想", event_date: Date.new(2025, 1, 1), amount: 30, payment_span: 1
    )
  end


  describe 'アソシエーションテスト' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
  end

  describe 'enumテスト' do
    it 'event_typeが正しい値を持つ' do
      expect(described_class.event_types).to eq({ "現実" => 0, "理想" => 1 })
    end
  end

  describe 'バリデーションテスト' do
    let(:life_event) { build(:life_event) }

    context '必須項目の確認' do
      it { is_expected.to validate_presence_of(:user_id) }
      it { is_expected.to validate_presence_of(:simulation_id) }

      it 'イベントタイプは必須' do
        life_event.event_type = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:event_type]).to include("イベントタイプを選択してください。")
      end

      it '時期は必須' do
        life_event.event_date = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:event_date]).to include("時期を選択してください。")
      end

      it 'タイトルは必須' do
        life_event.title = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:title]).to include("タイトルを入力してください。")
      end

      it '年額は必須' do
        life_event.amount = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:amount]).to include("年額を入力してください。")
      end

      it '支払期間は必須' do
        life_event.payment_span = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:payment_span]).to include("支払期間を選択してください。")
      end
    end

    context 'プラス値入力の確認' do
      it '年額が0以上' do
        life_event.amount = -1
        expect(life_event).not_to be_valid
        expect(life_event.errors[:amount]).to include("年額はプラス値で入力してください。")
      end
    end

    context '数値入力の確認' do
      it '年額が数値である' do
        life_event.amount = 'abc'
        expect(life_event).not_to be_valid
        expect(life_event.errors[:amount]).to include("数値を入力して下さい。")
      end
    end
  end

  describe ".generate_life_event_data_for" do
    let(:life_events) { double('life_events') }
    let(:real_events) { double('real_events') }
    let(:ideal_events) { double('ideal_events') }
    let(:real_event_data) { { some: 'data' } }
    let(:ideal_event_data) { { other: 'data' } }
    
    before do
      allow(described_class).to receive(:where).with(user: user).and_return(life_events)
      allow(life_events).to receive(:where).with(event_type: 0).and_return(real_events)
      allow(life_events).to receive(:where).with(event_type: 1).and_return(ideal_events)
      allow(described_class).to receive(:aggregate_event_data).with(real_events).and_return(real_event_data)
      allow(described_class).to receive(:aggregate_combined_event_data).with(real_events, ideal_events).and_return(ideal_event_data)
    end
  
    it "内部メソッドが正しく呼ばれ戻り値を返す" do
      result = described_class.generate_life_event_data_for(user)

      # where
      expect(described_class).to have_received(:where).with(user: user)
      expect(life_events).to have_received(:where).with(event_type: 0)
      expect(life_events).to have_received(:where).with(event_type: 1)

      # aggregate_event_data と aggregate_combined_event_data
      expect(described_class).to have_received(:aggregate_event_data).with(real_events)
      expect(described_class).to have_received(:aggregate_combined_event_data).with(real_events, ideal_events)

      # 戻り値
      expect(result).to eq({ real_event_data: real_event_data, ideal_event_data: ideal_event_data })
    end
  end

  describe ".extract_yearly_amounts" do
    it "イベントごとに支払期間分の金額を正しく算出する" do
      events = [real_event1, real_event2]
      result = described_class.send(:extract_yearly_amounts, events)

      expect(result).to contain_exactly({ date: 2025, amount: -10 }, { date: 2026, amount: -10 }, { date: 2026, amount: -20 })
    end
  end

  describe ".aggregate_by_year" do
    it "年毎に金額を合算する" do
      yearly_amounts = [{ date: 2025, amount: -10 }, { date: 2026, amount: -10 }, { date: 2026, amount: -20 }]

      result = described_class.send(:aggregate_by_year, yearly_amounts)
      expect(result).to contain_exactly({ date: 2025, amount: -10 }, { date: 2026, amount: -30 })
    end
  end

  describe ".aggregate_event_data" do
    it "イベントのデータを正しく集計する" do
      events = [real_event1, real_event2]
      result = described_class.send(:aggregate_event_data, events)

      expect(result).to contain_exactly({ date: 2025, amount: -10 }, { date: 2026, amount: -30 })
    end
  end

  describe ".aggregate_combined_event_data" do
    let(:real_event1) { { date: 2025, amount: -10 } }
    let(:real_event2) { { date: 2026, amount: -30 } }
    let(:ideal_event1) { { date: 2025, amount: -50 } }
  
    before do
      allow(described_class).to receive(:aggregate_event_data).with([real_event1, real_event2])
      allow(described_class).to receive(:aggregate_event_data).with([ideal_event1])
      allow(described_class).to receive(:merge_yearly_amounts)
    end
  
    it "内部メソッドが正しく呼ばれる" do
      described_class.aggregate_combined_event_data([real_event1, real_event2], [ideal_event1])
  
      expect(described_class).to have_received(:aggregate_event_data).with([real_event1, real_event2])
      expect(described_class).to have_received(:aggregate_event_data).with([ideal_event1])
      expect(described_class).to have_received(:merge_yearly_amounts)
    end
  end

  describe ".merge_yearly_amounts" do
    it "現実と理想のイベントデータを統合する" do
      real_data = [{ date: 2025, amount: -10 }, { date: 2026, amount: -30 }]
      ideal_data = [{ date: 2025, amount: -50 }, { date: 2027, amount: -20 }]

      result = described_class.send(:merge_yearly_amounts, real_data, ideal_data)

      expect(result).to contain_exactly({ date: 2025, amount: -60 }, { date: 2026, amount: -30 }, { date: 2027, amount: -20 })
    end
  end
end


