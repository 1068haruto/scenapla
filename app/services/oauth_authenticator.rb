class OauthAuthenticator
  attr_reader :auth

  def initialize(auth)
    @auth = auth
  end

  # SNS情報でユーザー検索/作成-> Userオブジェクト
  def find_or_create_user
    sns = SnsCredential.find_or_create_by(
      uid: auth.uid,
      provider: auth.provider
    )

    db_user = User.find_by(email: auth.info.email)
    user = sns.user || db_user || create_user_from_auth

    # 関連付け
    sns.user = user
    sns.save!
    user
  end

  private

  # ユーザー作成-> Userオブジェクト
  def create_user_from_auth
    user = User.new(
      email: auth.info.email,
      name: auth.info.name,
      password: Devise.friendly_token(10) + "a1",
      date_of_birth: nil, # 生年月日は別で登録
      confirmed_at: Time.current
    )
    # 保存（バリデーションスキップ）
    user.save(validate: false)
    user
  end
end
