class User < ApplicationRecord
  include Constants

  # Others available are :lockable, :timeoutable, :trackable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :incomes, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :user_assets, dependent: :destroy
  has_many :life_events, dependent: :destroy
  has_many :memos, dependent: :destroy
  has_one :simulation, dependent: :destroy
  has_many :scenarios, dependent: :destroy
  has_many :asset_lifespans, dependent: :destroy
  has_many :ai_advices, dependent: :destroy
  has_many :sns_credentials, dependent: :destroy

  # カスタムのみ（email形式は、devise.rbで定義）
  validates :name, presence: true
  validates :date_of_birth, presence: true, if: :date_of_birth_required?
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, format: { with: /\A(?=.*[a-z])(?=.*\d)[a-z\d]{8,}\z/ }, if: :password_required?
  validates :password_confirmation, presence: true, if: -> { password.present? }

  after_create :initialize_simulation_and_scenarios

  # SNSユーザー：登録は無効、更新は有効
  # 一般ユーザー：登録も更新も有効
  def date_of_birth_required?
    sns_credentials.empty? || !new_record?
  end

  # SNSユーザー：登録も更新も無効
  # 一般ユーザー：登録は有効、更新は入力あれば有効/なければ無効
  def password_required?
    return false if sns_credentials.exists?
    new_record? || password.present? || password_confirmation.present?
  end

  def active_for_authentication?
    # 生年月日が設定済なら認証を許可
    super && date_of_birth.present?
  end

  def get_user_age
    current_date = Date.today
    age = current_date.year - date_of_birth.year
    # 誕生日がまだなら1歳引く
    age -= 1 if current_date < date_of_birth + age.years
    age
  end

  def get_year_at_seventy
    date_of_birth.year + AGE_LIMIT
  end

  def initialize_simulation_and_scenarios
    simulation = create_simulation!
    simulation.scenarios.create!([
      { user: self, scenario_type: "現実" },
      { user: self, scenario_type: "理想" }
    ])
  end
end
