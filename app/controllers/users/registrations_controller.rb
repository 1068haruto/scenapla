# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  before_action :configure_permitted_parameters

  def create
    super do |resource|
      if resource.persisted? && resource.sns_credentials.empty?
        sign_out resource unless resource.confirmed?
      end
    end
  end

  def update
    if resource.update(account_update_params)
      redirect_to user_path(resource), notice: 'アカウント情報が更新されました'
    else
      render :edit
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
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :date_of_birth])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :date_of_birth])
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
end
