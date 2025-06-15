class UserAssetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_assets, only: [ :index, :create, :edit, :update, :destroy ]
  before_action :set_user_asset, only: [ :edit, :update, :destroy ]

  def index
    @user_asset = UserAsset.new
  end

  def create
    @user_asset = current_user.user_assets.build(user_asset_params)
    @user_asset.simulation = current_user.simulation

    if @user_asset.save
      redirect_to user_assets_path, notice: t("message.user_asset.create.success")
    else
      render_error(@user_asset.errors.full_messages.join(", "), :unprocessable_entity)
    end
  end

  def edit
    if @user_asset
      render :index
    else
      render_error(t("message.user_assets.edit.failure"), :not_found)
    end
  end

  def update
    if @user_asset.update(user_asset_params)
      redirect_to user_assets_path, notice: t("message.user_asset.update.success")
    else
      render_error(@user_asset.errors.full_messages.join(", "), :unprocessable_entity)
    end
  end

  def destroy
    if @user_asset.destroy
      redirect_to user_assets_path, notice: t("message.user_asset.destroy.success")
    else
      render_error(t("message.user_assets.destroy.failure"), :not_found)
    end
  end

  private

  def set_user_assets
    @user_assets = current_user.user_assets
  end

  def set_user_asset
    @user_asset = current_user.user_assets.find(params[:id])
  end

  def user_asset_params
    params.require(:user_asset).permit(:person_type, :asset_type, :amount, :return_rate)
  end

  def render_error(message, status)
    flash.now[:alert] = message
    render :index, status: status
  end
end
