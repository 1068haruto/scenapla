require 'rails_helper'

RSpec.describe LifeEvent, type: :model do
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
end
