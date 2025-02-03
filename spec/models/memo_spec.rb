require 'rails_helper'

RSpec.describe Memo, type: :model do
  let(:user) { create(:user) }
  let(:memo) { create(:memo, user: user) }

  describe 'アソシエーションテスト' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'バリデーションテスト' do
    it { is_expected.to validate_presence_of(:age_group) }
  end
end
