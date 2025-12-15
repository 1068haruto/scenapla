class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_user_for_dob_registration, only: [ :edit_dob, :update_dob ]
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
      notice: t("message.devise.registration.update.success")
    else
      flash.now[:alert] = t("message.devise.registration.update.failure")
      render :edit, status: :unprocessable_entity
    end
  end

  # 生年月日登録ページ
  def edit_dob; end

  # 生年月日登録
  def update_dob
    if user_signed_in?
      update_dob_for_user
    else
      redirect_to new_user_session_path,
      alert: t("message.devise.registration.update.not_sign_in")
    end
  end

  # user取得（生年月日登録用）
  def set_user_for_dob_registration
    return if user_signed_in?

    if session[:sns_user_id].present?
      @user_for_dob = User.find_by(id: session[:sns_user_id])

      unless @user_for_dob && @user_for_dob.date_of_birth.nil?
        # セッションにユーザーが存在せず、生年月日設定済の場合
        session.delete(:sns_user_id)
        redirect_to new_user_session_path,
        alert: "認証セッションが無効です。"
      end
    else
      redirect_to new_user_session_path,
      alert: t("message.devise.registration.update.not_sign_in")
    end
  end

  def current_user
    # 認証済は current_user、未認証は @user_for_dob を使用
    super || @user_for_dob
  end

  protected

  # 追加パラメータの許可
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :date_of_birth ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :date_of_birth ])
  end

  private

  def update_dob_for_user
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
