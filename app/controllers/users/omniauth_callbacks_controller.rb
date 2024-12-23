# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end

  # Google用のメソッド
  def google_oauth2
    callback_for(:google)
  end

  private

  def callback_for(provider)
    auth = request.env["omniauth.auth"]

    @user = User.find_or_create_for_oauth(auth)

    if @user.persisted?

      @user.skip_confirmation! if auth.provider.present?  # SNSログイン時はメールアドレス確認をスキップ

      # サインインしてリダイレクト
      sign_in @user, event: :authentication
      redirect_to dashboard_path, notice: "#{provider.to_s.capitalize}でログインしました。"
    else
      # 失敗時のリダイレクト先を統一
      redirect_to new_user_registration_url, alert: "#{provider.to_s.capitalize}ログインに失敗しました。"
    end
  end

  def failure
    redirect_to root_path
  end
end
