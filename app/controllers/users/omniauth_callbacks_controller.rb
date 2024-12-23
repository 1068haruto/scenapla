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

  def google_oauth2
    auth = request.env["omniauth.auth"]

    @user = User.find_or_create_for_oauth(auth)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      redirect_to new_user_registration_url, alert: "SNSログインに失敗しました。"
    end
  end

  def callback_for(provider)
    @omniauth = request.env["omniauth.auth"]
    info = User.find_oauth(@omniauth)
    @user = info[:user]
    @sns = info[:sns]
    if @user.persisted? # 保存完了しているかを確認する
      @user.skip_confirmation! if @user.provider.present?  # SNSログイン時はメールアドレス確認をスキップ
      sign_in @user, event: :authentication
      redirect_to dashboard_path
      # is_navigational_formatはフラッシュメッセージ表示の必要があるかどうかを確認
      # capitalizeは文字列の先頭を大文字に、それ以外は小文字に変更して返すメソッド
      set_flash_message(:notice, :success, kind: provider.to_s.capitalize) if is_navigational_format?
    else
      render template: "devise/registrations/new"
    end
  end

  def failure
    redirect_to root_path and return
  end
end
