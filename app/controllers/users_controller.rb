class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to user_path(current_user), notice: 'アカウント情報が更新されました'
    else
      render :edit
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:name, :email, :date_of_birth).tap do |whitelisted|
      whitelisted[:password] = params[:user][:password] if params[:user][:password].present?
      whitelisted[:password_confirmation] = params[:user][:password_confirmation] if params[:user][:password_confirmation].present?
    end
  end
end
