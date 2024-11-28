class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :incomes, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :user_assets, dependent: :destroy
  has_one :simulation, dependent: :destroy
  has_many :scenarios, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true, 
            format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "は有効なメールアドレスである必要があります" }
  validates :password, presence: true, length: { in: 8..128 }, 
            format: { with: /(?=.*[a-z])(?=.*\d)/, message: "は小文字と数字を含める必要があります" }, if: :password_present?
  validates :password_confirmation, presence: true, if: :password_present?

  # ユーザー作成後に計算モデルと結果モデルを作成
  after_create :create_simulation_and_scenario_models

  private

  def create_simulation_and_scenario_models
    # 計算モデルを作成
    Simulation.create(user: self)
    # 結果モデルを作成
    Scenario.create(user: self, simulation: simulation)
  end

  def password_present?
    password.present?
  end
end
