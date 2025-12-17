class User < ApplicationRecord
  include Constants
  include AgeCalculatable # 全Userオブジェクトに適用

  # others available are :lockable, :timeoutable, :trackable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable,
         omniauth_providers: [ :google_oauth2 ]

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

  # only custom（email形式はdevise委譲）
  validates :name, presence: true
  validates :date_of_birth, presence: true,
              if: :date_of_birth_required?
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true,
              format: { with: /\A(?=.*[a-z])(?=.*\d)[a-z\d]{8,}\z/ },
              if: :password_required?
  validates :password_confirmation, presence: true,
              if: -> { password.present? }

  after_create :initialize_simulation_and_scenarios

  # SNSuser：登録はoff、更新はon
  # 一般user：登録も更新もon
  def date_of_birth_required?
    sns_credentials.empty? || !new_record?
  end

  # SNSuser：登録も更新もoff
  # 一般user：登録はon、更新は入力ありでon/なしでoff
  def password_required?
    return false if sns_credentials.exists?
    new_record? || password.present? || password_confirmation.present?
  end

  def active_for_authentication?
    # dob設定済なら認証許可
    super && date_of_birth.present?
  end

  def initialize_simulation_and_scenarios
    simulation = create_simulation!
    simulation.scenarios.create!([
      { user: self, scenario_type: "現実" },
      { user: self, scenario_type: "理想" }
    ])
  end
end
