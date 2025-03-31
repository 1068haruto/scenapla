require 'rails_helper'

RSpec.describe SnsCredential, type: :model do
  let(:user) { create(:user) }
  let(:sns_credential) { build(:sns_credential, user: user) }

  describe 'アソシエーションテスト' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'バリデーションテスト' do
    context '必須項目の確認' do
      it 'providerは必須' do
        sns_credential.provider = nil
        expect(sns_credential).not_to be_valid
      end

      it 'uidは必須' do
        sns_credential.uid = nil
        expect(sns_credential).not_to be_valid
      end
    end
  end
end
