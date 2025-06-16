require 'rails_helper'

RSpec.describe LifeEvent, type: :model do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }

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
      it 'user_idは必須' do
        life_event.user_id = nil
        expect(life_event).not_to be_valid
      end

      it 'simulation_idは必須' do
        life_event.simulation_id = nil
        expect(life_event).not_to be_valid
      end

      it 'イベントタイプは必須' do
        life_event.event_type = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:event_type]).to include("イベントタイプを入力してください。")
      end

      it '時期は必須' do
        life_event.event_date = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:event_date]).to include("時期を入力してください。")
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
        life_event.payment_period = nil
        expect(life_event).not_to be_valid
        expect(life_event.errors[:payment_period]).to include("支払期間を入力してください。")
      end
    end

    context 'プラス値入力の確認' do
      it '年額は0以上' do
        life_event.amount = -1
        expect(life_event).not_to be_valid
        expect(life_event.errors[:amount]).to include("年額はプラス値で入力してください。")
      end
    end

    context '数値入力の確認' do
      it '年額が文字列の場合、無効' do
        life_event.amount = 'abc'
        expect(life_event).not_to be_valid
        expect(life_event.errors[:amount]).to include("数値を入力してください。")
      end
    end
  end

  describe ".generate_life_event_data_for" do
    let(:life_events) { double('life_events') }
    let(:real_events) { [ double('real_event1'), double('real_event2') ] }
    let(:ideal_events) { [ double('ideal_event1'), double('ideal_event2') ] }
    let(:real_event_data) { { some: 'real_data' } }
    let(:ideal_event_data) { { some: 'ideal_data' } }

    before do
      allow(described_class).to receive(:where).with(user: user).and_return(life_events)
      allow(life_events).to receive(:where).with(event_type: 0).and_return(real_events)
      allow(life_events).to receive(:where).with(event_type: 1).and_return(ideal_events)
      allow(described_class).to receive(:aggregate_event_data).with(real_events).and_return(real_event_data)
    end

    context "ideal_eventsが存在する場合" do
      before do
        allow(ideal_events).to receive(:present?).and_return(true)
        allow(described_class).to receive(:aggregate_event_data).with(real_events + ideal_events).and_return(ideal_event_data)
      end

      it "内部メソッドが正しく呼ばれ、結合された理想データを返す" do
        result = described_class.generate_life_event_data_for(user)

        expect(described_class).to have_received(:where).with(user: user)
        expect(life_events).to have_received(:where).with(event_type: 0)
        expect(life_events).to have_received(:where).with(event_type: 1)
        expect(described_class).to have_received(:aggregate_event_data).with(real_events)
        expect(described_class).to have_received(:aggregate_event_data).with(real_events + ideal_events)

        expect(result).to eq({ real_event_data: real_event_data, ideal_event_data: ideal_event_data })
      end
    end

    context "ideal_events が存在しない場合" do
      before do
        allow(ideal_events).to receive(:present?).and_return(false)
      end

      it "内部メソッドが正しく呼ばれ、理想データはnilを返す" do
        result = described_class.generate_life_event_data_for(user)

        expect(described_class).to have_received(:where).with(user: user)
        expect(life_events).to have_received(:where).with(event_type: 0)
        expect(life_events).to have_received(:where).with(event_type: 1)
        expect(described_class).to have_received(:aggregate_event_data).with(real_events)
        expect(described_class).not_to have_received(:aggregate_event_data).with(real_events + ideal_events)

        expect(result).to eq({ real_event_data: real_event_data, ideal_event_data: nil })
      end
    end
  end

  describe ".aggregate_by_year" do
    it "年毎に金額を合算する" do
      yearly_amounts = [ { date: 2025, amount: -10 }, { date: 2026, amount: -10 }, { date: 2026, amount: -20 } ]

      result = described_class.send(:aggregate_by_year, yearly_amounts)
      expect(result).to contain_exactly({ date: 2025, amount: -10 }, { date: 2026, amount: -30 })
    end
  end

  describe ".aggregate_event_data" do
    let(:real_event1) { double("real_event1", event_date: Date.new(2025, 1, 1), payment_period: 1, amount: 10) }
    let(:real_event2) { double("real_event2", event_date: Date.new(2026, 1, 1), payment_period: 1, amount: 30) }

    it "イベントのデータを集計する" do
      events = [ real_event1, real_event2 ]
      year_amounts = [ { date: 2025, amount: -10 }, { date: 2026, amount: -30 } ]

      allow(described_class).to receive(:extract_yearly_amounts).with(events).and_return(year_amounts)
      allow(described_class).to receive(:aggregate_by_year).with(year_amounts).and_return([
        { date: 2025, amount: -10 }, { date: 2026, amount: -30 }
      ])

      result = described_class.send(:aggregate_event_data, events)

      expect(result).to contain_exactly({ date: 2025, amount: -10 }, { date: 2026, amount: -30 })
    end
  end

  describe ".extract_yearly_amounts" do
    let(:real_event1) { double("real_event1", event_date: Date.new(2025, 1, 1), payment_period: 2, amount: 10) }
    let(:real_event2) { double("real_event2", event_date: Date.new(2026, 1, 1), payment_period: 1, amount: 20) }

    it "イベントごとに支払期間分の金額を正しく算出する" do
      events = [ real_event1, real_event2 ]
      result = described_class.send(:extract_yearly_amounts, events)

      expect(result).to contain_exactly(
        { date: 2025, amount: -10 },  # real_event1の1年目
        { date: 2026, amount: -10 },  # real_event1の2年目
        { date: 2026, amount: -20 }   # real_event2の1年目
      )
    end
  end
end
