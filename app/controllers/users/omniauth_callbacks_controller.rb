# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # Google用
  def google_oauth2
    callback_for(:google)
  end

  def failure
    # プロバイダー名取得
    provider = request.env["omniauth.error.strategy"].name

    redirect_to new_user_registration_path,
    alert: "#{provider.to_s.capitalize}#{t("message.devise.omniauth.failure")}"
  end

  private

  def callback_for(provider)
    auth = request.env["omniauth.auth"]
    @user = User.find_or_create_for_oauth(auth)

    if @user.persisted?
      # メール確認スキップ
      @user.skip_confirmation! if auth.provider.present?

      if @user.date_of_birth.present? && sign_in(@user, event: :authentication)
        # 認証成功（生年月日設定済）
        redirect_to dashboard_index_path,
        notice: "#{provider.to_s.capitalize}#{t('message.devise.omniauth.callback.success')}"
      elsif @user.date_of_birth.nil?
        # 認証失敗（生年月日未登録）
        session[:sns_user_id_for_dob_registration] = @user.id # 次ページで利用のため
        redirect_to edit_date_of_birth_path # Deviseのリダイレクト回避
      else
        # 他の理由で失敗
        redirect_to new_user_session_path,
        alert: "認証に失敗しました。再度お試しください。"
      end
    else
      redirect_to new_user_registration_path,
      alert: "#{provider.to_s.capitalize}#{t("message.devise.omniauth.callback.failure")}"
    end
  end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
