# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # Google用のメソッド
  def google_oauth2
    callback_for(:google)
  end

  def failure
    provider = request.env["omniauth.error.strategy"].name # プロバイダー名の取得
    redirect_to new_user_registration_path, alert: "#{provider.to_s.capitalize}#{t("alert.devise.omniauth.failure")}"
  end

  private

  def callback_for(provider)
    auth = request.env["omniauth.auth"]
    @user = User.find_or_create_for_oauth(auth)

    if @user.persisted?
      @user.skip_confirmation! if auth.provider.present?  # googleログイン時はメール確認をスキップ
      sign_in @user, event: :authentication
      redirect_after_auth(provider)
    else
      redirect_to new_user_registration_path, alert: "#{provider.to_s.capitalize}#{t("alert.devise.omniauth.callback.failure")}"
    end
  end

  def redirect_after_auth(provider)
    path = @user.date_of_birth.nil? ? edit_date_of_birth_path : dashboard_index_path
    redirect_to path, notice: "#{provider.to_s.capitalize}#{t('notice.devise.omniauth.callback.success')}"
  end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
