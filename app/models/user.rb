class User < ApplicationRecord
  # Others available are :lockable, :timeoutable, :trackable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: %i[google_oauth2]

  has_many :incomes, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :user_assets, dependent: :destroy
  has_many :life_events, dependent: :destroy
  has_many :memos, dependent: :destroy
  has_one :simulation, dependent: :destroy
  has_many :scenarios, dependent: :destroy
  has_many :asset_lifespans, dependent: :destroy
  has_many :sns_credentials, dependent: :destroy

  # カスタムのみ記述（email形式, password長さ, password_confirmationは、devise.rb側で定義）
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :date_of_birth, presence: true, if: :date_of_birth_required?
  validates :password, presence: true, format: { with: /(?=.*[a-z])(?=.*\d)/ }, if: :password_required?

  after_create :create_simulation_and_scenario_models

  def calculate_user_age
    current_date = Date.today
    age = current_date.year - date_of_birth.year
    age -= 1 if current_date < date_of_birth + age.years  # 誕生日がまだ来ていない場合は1歳引く
    age
  end

  # SNSログイン（ユーザーを検索or作成）
  def self.find_or_create_for_oauth(auth)
    sns = SnsCredential.find_or_create_by(uid: auth.uid, provider: auth.provider)
    user = sns.user || User.find_by(email: auth.info.email)
    if user.nil?
      user = self.create_user_from_auth(auth)
    end
    self.associate_sns_with_user(sns, user)
  end

  private

  # SNSユーザー：登録も更新も無効
  # 一般ユーザー：登録は有効、更新は入力があれば有効、なければ無効
  def password_required?
    if sns_credentials.exists?
      false
    elsif new_record?
      true
    else
      password.present? || password_confirmation.present?
    end
  end

  # SNS使用ユーザー：登録は無効、更新は有効
  # 一般ユーザー：登録も更新も有効
  def date_of_birth_required?
    return true if sns_credentials.empty?

    if sns_credentials.exists? && new_record?
      false
    else
      true
    end
  end

  def create_simulation_and_scenario_models
    Simulation.create(user: self)

    # 各scenario_typeに対応するテーブル作成
    scenario_types = [ "現実", "理想" ]
    scenario_types.each do |type|
      Scenario.create(user: self, simulation: simulation, scenario_type: type)
    end
  end

  # snsを元にuser作成
  def self.create_user_from_auth(auth)
    user = User.new(
      email: auth.info.email,
      name: auth.info.name,
      password: Devise.friendly_token(10) + "a1",
      date_of_birth: nil,  # 生年月日は未設定とする
      confirmed_at: Time.current
    )
    user.save(validate: false)  # バリデーションをスキップして保存
    user
  end

  # snsとuserの関連付け
  def self.associate_sns_with_user(sns, user)
    sns.user = user
    sns.save!
    user
  end
end
