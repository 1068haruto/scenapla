require 'rails_helper'

RSpec.describe LifeEvent, type: :model do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }

  describe 'Relation' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:simulation) }
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

  describe 'Method' do
    # '.generate_life_event_data'の疎結合テストは省略

    describe '#retirement_date=' do
      it '時期をDate型の年始に設定する' do
        life_event = build(:life_event, event_date: "2030")
        expect(life_event.event_date).to eq(Date.new(2030, 1, 1))
      end
    end
  end
end
