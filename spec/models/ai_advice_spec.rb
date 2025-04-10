require 'rails_helper'

RSpec.describe AiAdvice, type: :model do
  let!(:user) { create(:user) }
  let(:ai_advice) { build(:ai_advice, user: user) }

  describe 'アソシエーションテスト' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'バリデーションテスト' do
    context '必須項目の確認' do
      it 'user_idは必須' do
        ai_advice.user_id = nil
        expect(ai_advice).not_to be_valid
      end

      it 'contentは必須' do
        ai_advice.content = nil
        expect(ai_advice).not_to be_valid
      end

      it 'real_scenario_updated_atは必須' do
        ai_advice.real_scenario_updated_at = nil
        expect(ai_advice).not_to be_valid
      end
    end
  end
end
