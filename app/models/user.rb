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
  
  validates :name, presence: { message: "を入力して下さい" }
  validates :email, presence: true, uniqueness: true, 
            format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "は有効なメールアドレスである必要があります" }
  validates :date_of_birth,
            format: { with: /\A\d{4}-\d{2}-\d{2}\z/, message: 'はYYYY-MM-DD形式で入力してください' },
            if: :date_of_birth_required?
  # SNSログインでない場合のみ有効、password_confirmationはDeviseのバリデーションでカバー（validatableモジュール確認）
  validates :password, presence: true, length: { in: 8..128 },
            format: { with: /(?=.*[a-z])(?=.*\d)/, message: "は小文字と数字を含める必要があります" },
            if: :password_required?

  after_create :create_simulation_and_scenario_models  # ユーザー作成後に計算モデル＆結果モデルを作成

  # 生年月日から年齢を計算
  def age
    today = Date.today
    age = today.year - date_of_birth.year
    age -= 1 if today < date_of_birth + age.years  # 誕生日がまだ来ていない場合は1歳引く
    age
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
        password: Devise.friendly_token(10) + "a1",
        date_of_birth: nil,  # 生年月日は未設定とする
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

  # SNS使用ユーザー：登録も更新も無効
  # 一般ユーザー：登録は常に有効、更新は入力があれば有効、なければ無効
  def password_required?
    if sns_credentials.exists?  
      false
    elsif new_record?    
      true
    else                        
      password.present? || password_confirmation.present? 
    end
  end

  # 一般ユーザー：登録も更新も有効
  # SNS使用ユーザー：登録は無効、更新は有効
  def date_of_birth_required?
    return true if sns_credentials.empty?    

    if sns_credentials.exists? && new_record?
      false
    else
      true
    end
  end

  def create_simulation_and_scenario_models
    Simulation.create(user: self)  # simulationsテーブル作成

    scenario_types = ['現実', '理想']  # シナリオのタイプを配列に定義
    # 各シナリオタイプに対応するscenariosテーブル作成
    scenario_types.each do |type|
      Scenario.create(user: self, simulation: simulation, scenario_type: type)
    end
  end
end
