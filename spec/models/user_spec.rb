require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.build(:user) }

  describe 'アソシエーションのテスト' do
    it { should have_many(:incomes).dependent(:destroy) }
    it { should have_many(:expenses).dependent(:destroy) }
    it { should have_many(:user_assets).dependent(:destroy) }
    it { should have_many(:life_events).dependent(:destroy) }
    it { should have_many(:memos).dependent(:destroy) }
    it { should have_many(:scenarios).dependent(:destroy) }
    it { should have_many(:asset_lifespans).dependent(:destroy) }
    it { should have_many(:sns_credentials).dependent(:destroy) }
    it { should have_one(:simulation).dependent(:destroy) }
  end

  describe 'バリデーションのテスト' do
    context '必須項目の確認' do
      it 'ユーザー名が必須であること' do
        user.name = nil
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include("ユーザー名を入力してください。")
      end

      it '生年月日が必須であること' do
        user.date_of_birth = nil
        expect(user).not_to be_valid
        expect(user.errors[:date_of_birth]).to include("生年月日を入力してください。")
      end

      it 'メールアドレスが必須であること' do
        user.email = nil
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("メールアドレスを入力してください。")
      end

      it 'パスワードが必須であること' do
        user.password = nil
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("パスワードを入力してください。")
      end

      it '確認用パスワードが必須であること' do
        user.password_confirmation = nil
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("確認用パスワードを入力してください。")
      end
    end

    it 'パスワードと確認用パスワードが一致しない場合、無効であること' do
      user.password_confirmation = "different_password"
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("パスワードが一致していません。")
    end

    context 'パスワードの長さ' do
      it '8字未満は無効であること' do
        user.password = 'short'
        user.password_confirmation = 'short'
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("パスワードは8字以上30字以下としてください。")
      end

      it '30字を超える場合は無効であること' do
        user.password = 'a' * 31
        user.password_confirmation = 'a' * 31
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("パスワードは8字以上30字以下としてください。")
      end
    end

    context 'パスワードの形式（英数字）' do
      it '文字のみのパスワードは無効であること' do
        user.password = 'onlyletters'
        user.password_confirmation = 'onlyletters'
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("パスワードは英数字である必要があります。")
      end

      it '数字のみのパスワードは無効であること' do
        user.password = '1234567890'
        user.password_confirmation = '1234567890'
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("パスワードは英数字である必要があります。")
      end
    end
  end

  describe 'カスタムバリデーションのテスト' do
    describe '#password_required?' do
      it 'SNSユーザーは、パスワードは不要であること' do
        sns_mock = double('SnsCredential', exists?: true)
        allow(user).to receive(:sns_credentials).and_return(sns_mock)
        expect(user.send(:password_required?)).to be false
      end

      it '一般ユーザーは、パスワードが必須であること' do
        sns_mock = double('SnsCredential', exists?: false)
        allow(user).to receive(:sns_credentials).and_return(sns_mock)
        expect(user.send(:password_required?)).to be true
      end
    end

    describe '#date_of_birth_required?' do
      it 'SNSユーザーは、生年月日は不要であること' do
        sns_mock = double('SnsCredential', empty?: false, exists?: true)
        allow(user).to receive(:sns_credentials).and_return(sns_mock)
        expect(user.send(:date_of_birth_required?)).to be false
      end

      it 'SNSユーザーが既存レコードのとき、生年月日は必須であること' do
        sns_mock = double('SnsCredential', empty?: false, exists?: true)
        allow(user).to receive(:sns_credentials).and_return(sns_mock)
        allow(user).to receive(:new_record?).and_return(false)
        expect(user.send(:date_of_birth_required?)).to be true
      end

      it '一般ユーザーは、生年月日が必須であること' do
        sns_mock = double('SnsCredential', empty?: true, exists?: false)
        allow(user).to receive(:sns_credentials).and_return(sns_mock)
        expect(user.send(:date_of_birth_required?)).to be true
      end
    end
  end

  describe 'コールバックのテスト' do
    it 'ユーザー作成後にシミュレーションとシナリオを作成すること' do
      user = FactoryBot.create(:user)
      expect(user.simulation).to be_present
      expect(user.scenarios.count).to eq 2
      expect(user.scenarios.map(&:scenario_type)).to contain_exactly("現実", "理想")
    end
  end

  describe 'クラスメソッドのテスト' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        uid: "12345",
        provider: "google_oauth2",
        info: { email: "test@example.com", name: "テストユーザー" }
      )
    end

    describe '.find_or_create_for_oauth' do
      it '既存のユーザーが存在する場合、そのユーザーを返すこと' do
        existing_user = FactoryBot.create(:user, email: auth.info.email)
        user = User.find_or_create_for_oauth(auth)
        expect(user).to eq existing_user
      end

      it 'ユーザーが存在しない場合、ユーザーを新規作成すること' do
        user = User.find_or_create_for_oauth(auth)
        expect(user.email).to eq "test@example.com"
        expect(user.name).to eq "テストユーザー"
      end
    end

    describe '.create_user_from_auth' do
      it 'SNS認証を用いた新規ユーザーを作成すること' do
        user = User.create_user_from_auth(auth)
        expect(user.email).to eq "test@example.com"
        expect(user.name).to eq "テストユーザー"
        expect(user.confirmed?).to be true
      end
    end
  end

  describe 'インスタンスメソッドのテスト' do
    describe '#calculate_user_age' do
      it '生年月日から年齢を計算できる' do
        allow(Date).to receive(:today).and_return(Date.new(2025, 1, 1)) # テスト用の固定日
        expect(user.calculate_user_age).to eq 35
      end
    end
  end
end
