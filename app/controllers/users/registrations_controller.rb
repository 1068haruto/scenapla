class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, only: [ :edit_date_of_birth, :update_date_of_birth ]
  before_action :configure_permitted_parameters

  def create
    super do |resource|
      if resource.persisted? && resource.sns_credentials.empty?
        sign_out resource unless resource.confirmed?  # 一般ユーザー用
      end
    end
  end

  def update
    if resource.update(account_update_params)
      redirect_to user_path(resource), notice: t("message.devise.registration.update.success")
    else
      flash.now[:alert] = t("message.devise.registration.update.failure")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_to root_path
  end

  def edit_date_of_birth; end

  def update_date_of_birth
    if user_signed_in?
      update_date_of_birth_for_user
    else
      redirect_to new_user_session_path, alert: t("message.devise.registration.update.not_sign_in")
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
    if current_user.update(date_of_birth_params)
      redirect_to dashboard_index_path, notice: t("message.devise.registration.update_date_of_birth.success")
    else
      flash.now[:alert] = t("message.devise.registration.update_date_of_birth.failure")
      render :edit_date_of_birth, status: :unprocessable_entity
    end
  end

  def date_of_birth_params
    params.require(:user).permit(:date_of_birth)
  end
end
