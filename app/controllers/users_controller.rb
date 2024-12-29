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
    params.require(:user).permit(:name, :email, :date_of_birth, :password, :password_confirmation)
  end
end
