require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe 'Relation' do
    it { is_expected.to have_many(:incomes).dependent(:destroy) }
    it { is_expected.to have_many(:expenses).dependent(:destroy) }
    it { is_expected.to have_many(:user_assets).dependent(:destroy) }
    it { is_expected.to have_many(:life_events).dependent(:destroy) }
    it { is_expected.to have_many(:memos).dependent(:destroy) }
    it { is_expected.to have_many(:scenarios).dependent(:destroy) }
    it { is_expected.to have_many(:asset_lifespans).dependent(:destroy) }
    it { is_expected.to have_many(:sns_credentials).dependent(:destroy) }
    it { is_expected.to have_one(:simulation).dependent(:destroy) }
  end

  describe 'Validation' do
    context '必須項目' do
      it 'ユーザー名なしは、無効' do
        user.name = nil
        expect(user).not_to be_valid
      end

      it '生年月日なしは、無効' do
        user.date_of_birth = nil
        expect(user).not_to be_valid
      end

      it 'メールアドレスなしは、無効' do
        user.email = nil
        expect(user).not_to be_valid
      end

      it 'パスワードなしは、無効' do
        user.password = nil
        expect(user).not_to be_valid
      end

      it '確認用パスワードなしは、無効' do
        user.password_confirmation = nil
        expect(user).not_to be_valid
      end
    end

    it 'パスワードと確認用パスワードが不一致の場合、無効' do
      user.password_confirmation = "different_password"
      expect(user).not_to be_valid
    end

    context 'パスワードの長さ' do
      it '8字未満は、無効' do
        user.password = 'short'
        user.password_confirmation = 'short'
        expect(user).not_to be_valid
      end

      it '30字以上は、無効' do
        user.password = 'a' * 31
        user.password_confirmation = 'a' * 31
        expect(user).not_to be_valid
      end
    end

    context 'パスワードの形式（半角英数字8~30字）' do
      it '文字のみなら、無効' do
        user.password = 'onlyletters'
        user.password_confirmation = 'onlyletters'
        expect(user).not_to be_valid
      end

      it '数字のみなら、無効' do
        user.password = '1234567890'
        user.password_confirmation = '1234567890'
        expect(user).not_to be_valid
      end

      it '大文字を含むなら、無効' do
        user.password = 'ABC123'
        user.password_confirmation = 'ABC123'
        expect(user).not_to be_valid
      end

      it '特殊文字を含むなら、無効' do
        user.password = 'abcd@123'
        user.password_confirmation = 'abcd@123'
        expect(user).not_to be_valid
      end
    end
  end

  describe 'Custom Validation' do
    describe '#password_required?' do
      it 'SNSuserは、パスワード不要' do
        sns_mock = double('SnsCredential', exists?: true)
        allow(user).to receive(:sns_credentials).and_return(sns_mock)
        expect(user.send(:password_required?)).to be false
      end

      it '新規一般userは、パスワード必須' do
        sns_mock = double('SnsCredential', exists?: false)
        allow(user).to receive(:sns_credentials).and_return(sns_mock)
        allow(user).to receive(:new_record?).and_return(true)
        expect(user.send(:password_required?)).to be true
      end

      it '既存一般userは、パスワード不要（未入力の場合）' do
        sns_mock = double('SnsCredential', exists?: false)
        allow(user).to receive(:sns_credentials).and_return(sns_mock)
        allow(user).to receive(:new_record?).and_return(false)
        allow(user).to receive(:password).and_return(nil)
        allow(user).to receive(:password_confirmation).and_return(nil)
        expect(user.send(:password_required?)).to be false
      end

      it '既存一般userは、パスワード必須（入力された場合）' do
        sns_mock = double('SnsCredential', exists?: false)
        allow(user).to receive(:sns_credentials).and_return(sns_mock)
        allow(user).to receive(:new_record?).and_return(false)
        allow(user).to receive(:password).and_return('changepassword')
        allow(user).to receive(:password_confirmation).and_return('changepassword')
        expect(user.send(:password_required?)).to be true
      end
    end

    describe '#date_of_birth_required?' do
      it '新規SNSuserは、生年月日不要' do
        sns_mock = double('SnsCredential', empty?: false)
        allow(user).to receive(:sns_credentials).and_return(sns_mock)
        allow(user).to receive(:new_record?).and_return(true)
        expect(user.send(:date_of_birth_required?)).to be false
      end

      it '既存SNSuserは、生年月日必須' do
        sns_mock = double('SnsCredential', empty?: false)
        allow(user).to receive(:sns_credentials).and_return(sns_mock)
        allow(user).to receive(:new_record?).and_return(false)
        expect(user.send(:date_of_birth_required?)).to be true
      end

      it '一般ユーザーは、生年月日必須' do
        sns_mock = double('SnsCredential', empty?: true)
        allow(user).to receive(:sns_credentials).and_return(sns_mock)
        expect(user.send(:date_of_birth_required?)).to be true
      end
    end
  end

  describe 'Callbacks' do
    it 'user作成後にシミュレーションとシナリオが作成される' do
      user = create(:user)
      expect(user.simulation).to be_present
      expect(user.scenarios.count).to eq 2
      expect(user.scenarios.map(&:scenario_type)).to contain_exactly("現実", "理想")
    end
  end
end
