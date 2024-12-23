class User < ApplicationRecord
  # Others available are :confirmable, :lockable, :timeoutable, :trackable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: %i[google_oauth2]

  has_many :incomes, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :user_assets, dependent: :destroy
  has_many :life_events, dependent: :destroy
  has_many :memos, dependent: :destroy
  has_one :simulation, dependent: :destroy
  has_many :scenarios, dependent: :destroy
  has_many :asset_lifespans, dependent: :destroy
  has_many :sns_credentials, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true, 
            format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "は有効なメールアドレスである必要があります" }
  # SNSログインでない場合のみ有効とし、password_confirmationはDeviseでのバリデーションでカバー（validatableモジュール確認）
  validates :password, presence: true, length: { in: 8..128 },
            format: { with: /(?=.*[a-z])(?=.*\d)/, message: "は小文字と数字を含める必要があります" }, if: :password_required?
  validates :date_of_birth, format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: 'はYYYY-MM-DD形式で入力してください' }, if: :date_of_birth_required?

  after_create :create_simulation_and_scenario_models  # ユーザー作成後に計算モデル＆結果モデルを作成

  # 生年月日から年齢を計算
  def age
    today = Date.today
    age = today.year - date_of_birth.year
    age -= 1 if today < date_of_birth + age.years  # 誕生日がまだ来ていない場合は1歳引く
    age
  end

  class << self
    def without_sns_data(auth)
      user = User.find_by(email: auth.info.email)

      if user.nil?
        user = User.create(
          name: auth.info.name,
          email: auth.info.email,
          date_of_birth: nil,
          password: Devise.friendly_token(10) + "a1",
          confirmed_at: Time.current
        )
      end

      sns = SnsCredential.create(uid: auth.uid, provider: auth.provider, user_id: user.id)
      { user:, sns: }
    end

    def with_sns_data(auth, snscredential)
      user = User.where(id: snscredential.user_id).first

      if user.blank?
        user = User.create(
          name: auth.info.name,
          email: auth.info.email,
          date_of_birth: nil,
          password: Devise.friendly_token(10) + "a1",
          confirmed_at: Time.current # 必要であれば自動的に確認済みにする
        )
      end

      { user: }
    end

    def find_oauth(auth)
      uid = auth.uid
      provider = auth.provider
      sns = SnsCredential.find_by(uid:, provider:)
      
      if sns.present?
        user = sns.user
      else
        user = without_sns_data(auth)[:user]
      end

      { user:, sns: }
    end
  end

  # SNSログイン用のユーザーを検索または作成
  def self.find_or_create_for_oauth(auth)
    sns = SnsCredential.find_or_create_by(uid: auth.uid, provider: auth.provider)
    user = sns.user || User.find_by(email: auth.info.email)

    if user.nil?
      # SNSログイン用のユーザーを新規作成
      user = User.new(
        email: auth.info.email,
        name: auth.info.name,
        password: Devise.friendly_token[0, 20], # 仮パスワードを設定
        date_of_birth: nil, # 生年月日は未設定にして保存
        confirmed_at: Time.current
      )

      user.save(validate: false)  # バリデーションをスキップして保存
    end

    # SNSとユーザーを関連付け
    sns.user = user
    sns.save!

    user
  end

  private

  def password_required?
    sns_credentials.empty?
  end
  
  def date_of_birth_required?
    sns_credentials.empty?
  end

  def create_simulation_and_scenario_models
    Simulation.create(user: self)  # 計算モデル作成

    scenario_types = ['現実', '理想']  # シナリオのタイプを配列に定義
    # 各シナリオタイプに対してシナリオを作成
    scenario_types.each do |type|
      Scenario.create(user: self, simulation: simulation, scenario_type: type)
    end
  end
end
