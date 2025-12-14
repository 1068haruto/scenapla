class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_user_for_dob_registration, only: [ :edit_date_of_birth, :update_date_of_birth ]
  before_action :configure_permitted_parameters

  # current_user取得（生年月日登録用）
  def set_user_for_dob_registration
    return if user_signed_in?

    if session[:sns_user_id_for_dob_registration].present?
      @user_for_dob = User.find_by(id: session[:sns_user_id_for_dob_registration])
      # ユーザー存在せず、生年月日設定済の場合
      unless @user_for_dob && @user_for_dob.date_of_birth.nil?
        session.delete(:sns_user_id_for_dob_registration)
        redirect_to new_user_session_path,
        alert: "認証セッションが無効です。"
      end
    else
      # セッション情報がない場合
      redirect_to new_user_session_path,
      alert: t("message.devise.registration.update.not_sign_in")
    end
  end

  def current_user
    # 認証済はcurrent_user、未認証は @user_for_dob
    super || @user_for_dob
  end

  def create
    # 一般ユーザー用
    super do |resource|
      if resource.persisted? && resource.sns_credentials.empty?
        sign_out resource unless resource.confirmed?
      end
    end
  end

  def update
    if resource.update(account_update_params)
      redirect_to user_path(resource),
      notice: t("message.devise.registration.update.success")
    else
      flash.now[:alert] = t("message.devise.registration.update.failure")
      render :edit, status: :unprocessable_entity
    end
  end

  def edit_date_of_birth; end

  def update_date_of_birth
    if user_signed_in?
      update_date_of_birth_for_user
    else
      redirect_to new_user_session_path,
      alert: t("message.devise.registration.update.not_sign_in")
    end
  end

  protected

  # 追加パラメータの許可
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :date_of_birth ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :date_of_birth ])
  end

  private

  def update_date_of_birth_for_user
    user_to_update = current_user
    if user_to_update.update(birth_params)
      # セッションをクリア & 正式ログイン
      session.delete(:sns_user_id_for_dob_registration)
      sign_in(user_to_update, event: :authentication)
      redirect_to dashboard_index_path,
      notice: t("message.devise.registration.update.date_of_birth")
    else
      flash.now[:alert] = t("message.devise.registration.update.date_of_birth_failed")
      render :edit_date_of_birth, status: :unprocessable_entity
    end
  end

  def birth_params
    params.require(:user).permit(:date_of_birth)
  end
end
