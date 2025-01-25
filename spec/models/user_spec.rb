require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションのテスト' do
    it '名前が必須であること' do
      user = FactoryBot.build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("を入力して下さい")
    end

    it 'メールアドレスが一意であること' do
      FactoryBot.create(:user, email: "test@example.com")
      duplicate_user = FactoryBot.build(:user, email: "test@example.com")
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include("はすでに存在します")
    end

    it 'パスワードが8文字以上128文字以内であること' do
      user = FactoryBot.build(:user, password: "short", password_confirmation: "short")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("は小文字と数字を含める必要があります")
    end
  end

  describe '関連付けのテスト' do
    it { should have_many(:incomes).dependent(:destroy) }
    it { should have_many(:expenses).dependent(:destroy) }
    it { should have_one(:simulation).dependent(:destroy) }
  end

  describe 'インスタンスメソッドのテスト' do
    describe '#age' do
      it '生年月日から年齢を計算すること' do
        user = FactoryBot.build(:user, date_of_birth: "2000-01-01")
        allow(Date).to receive(:today).and_return(Date.new(2025, 1, 1)) # テスト用の固定日
        expect(user.age).to eq 25
      end
    end
  end

  describe 'クラスメソッドのテスト' do
    describe '.find_or_create_for_oauth' do
      let(:auth) do
        OmniAuth::AuthHash.new(
          uid: "12345",
          provider: "google_oauth2",
          info: { email: "test@example.com", name: "テストユーザー" }
        )
      end

      it 'SNS認証でユーザーを作成すること' do
        user = User.find_or_create_for_oauth(auth)
        expect(user.email).to eq "test@example.com"
        expect(user.name).to eq "テストユーザー"
      end
    end
  end

  describe 'コールバックのテスト' do
    it 'ユーザー作成時にシミュレーションとシナリオを作成すること' do
      user = FactoryBot.create(:user)
      expect(user.simulation).to be_present
      expect(user.scenarios.count).to eq 2
      expect(user.scenarios.map(&:scenario_type)).to contain_exactly("現実", "理想")
    end
  end
end