# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  before_action :configure_permitted_parameters
  before_action :authenticate_user!, only: [ :edit_date_of_birth, :update_date_of_birth ]
  before_action :set_resource, only: [ :edit_date_of_birth, :update_date_of_birth ]

  def create
    super do |resource|
      if resource.persisted? && resource.sns_credentials.empty?
        sign_out resource unless resource.confirmed?  # SNS未使用ユーザー用
      end
    end
  end

  def update
    if resource.update(account_update_params)
      redirect_to user_path(resource), notice: "アカウント情報が更新されました"
    else
      render :edit
    end
  end

  def edit_date_of_birth; end  # 生年月日の単体登録ページ

  # 生年月日の単体登録処理
  def update_date_of_birth
    if current_user.update(date_of_birth_params)
      redirect_to dashboard_index_path, notice: "生年月日を登録しました。"
    else
      flash.now[:alert] = "生年月日の登録に失敗しました。"
      render :edit_date_of_birth, status: :unprocessable_entity
    end
  end

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  protected

  # 登録時、更新時の追加のパラメータを許可
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :date_of_birth ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :date_of_birth ])
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private

  def set_resource
    @resource = current_user
  end

  def date_of_birth_params
    params.require(:user).permit(:date_of_birth)
  end
end
