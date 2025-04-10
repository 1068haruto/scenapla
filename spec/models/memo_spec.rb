require 'rails_helper'

RSpec.describe Memo, type: :model do
  let(:user) { create(:user) }
  let(:memo) { build(:memo, user: user) }

  describe 'アソシエーションテスト' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'バリデーションテスト' do
    context '必須項目の確認' do
      it 'user_idは必須' do
        memo.user_id = nil
        expect(memo).not_to be_valid
      end

      it 'age_groupは必須' do
        memo.age_group = nil
        expect(memo).not_to be_valid
      end
    end
  end
end
