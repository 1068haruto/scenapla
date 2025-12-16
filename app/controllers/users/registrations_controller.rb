class Users::RegistrationsController < Devise::RegistrationsController
  include Constants

  before_action :set_user_to_update_dob, only: [ :edit_dob, :update_dob ]
  before_action :configure_permitted_parameters

  def create
    super do |resource|
      if resource.persisted? && resource.sns_credentials.empty?
        # 一般ユーザー用
        sign_out resource unless resource.confirmed?
      end
    end
  end

  def update
    if resource.update(account_update_params)
      redirect_to user_path(resource),
      notice: t("common.actions.update", data: ACCOUNT_INFO)
    else
      flash.now[:alert] = t("common.actions.update_failed", data: ACCOUNT_INFO)
      render :edit, status: :unprocessable_entity
    end
  end

  # dobs登録ページ
  def edit_dob; end

  # dob登録
  def update_dob
    user_to_update = current_user # @user_for_dob / 正規user

    if user_to_update.update(birth_params)
      session.delete(:sns_user_id)
      sign_in(user_to_update, event: :authentication)

      redirect_to dashboard_index_path,
      notice: t("dob.update_and_login", data: DATE_OF_BIRTH)
    else
      flash.now[:alert] = t("dob.update_faild", data: DATE_OF_BIRTH)
      render :edit_dob, status: :unprocessable_entity
    end
  end

  protected

  # 追加パラメータの許可
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :date_of_birth ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :date_of_birth ])
  end

  private

  # user取得（dob登録用）
  def set_user_to_update_dob
    return if user_signed_in?

    if session[:sns_user_id].present?
      @user_for_dob = User.find_by(id: session[:sns_user_id])

      # ユーザーがなく && dob登録済の場合
      unless @user_for_dob && @user_for_dob.date_of_birth.nil?
        session.delete(:sns_user_id)
        redirect_to new_user_session_path,
        alert: t("auth.invalid_auth_session")
      end
    else
      redirect_to new_user_session_path,
      alert: t("auth.not_sign_in")
    end
  end

  # current_user のオーバーライド
  # 認証済は 正規user、未認証は @user_for_dob
  def current_user
    super || @user_for_dob
  end

  def birth_params
    params.require(:user).permit(:date_of_birth)
  end
end
