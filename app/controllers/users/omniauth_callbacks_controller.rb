class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Google用
  def google_oauth2
    callback_for(:google)
  end

  def failure
    @provider_name = request.env["omniauth.error.strategy"].name.to_s.capitalize

    redirect_to new_user_registration_path,
    alert: t("devise.omniauth.failure", provider: @provider_name)
  end

  private

  def callback_for(provider)
    auth = request.env["omniauth.auth"]
    @user = OauthAuthenticator.new(auth).find_or_create_user
    @provider_name = provider.to_s.capitalize

    # ユーザーがいない場合、登録ページへ
    unless @user.persisted?
      redirect_to new_user_registration_path,
      alert: t("devise.omniauth.failure", provider: @provider_name)
      return
    end

    # メール確認スキップ
    @user.skip_confirmation! if auth.provider.present?

    # 生年月日未登録の場合、登録ページへ
    if @user.date_of_birth.nil?
      session[:sns_user_id] = @user.id
      redirect_to edit_dob_path
      return
    end

    # ログイン
    if sign_in(@user, event: :authentication)
      redirect_to dashboard_path,
      notice: t("devise.omniauth.success", provider: @provider_name)
    else
      redirect_to new_user_session_path,
      alert: t("devise.omniauth.failure", provider: @provider_name)
    end
  end
end
