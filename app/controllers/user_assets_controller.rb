class UserAssetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_incomes, only: [ :index, :create, :destroy ]

  def index
    @user_assets = current_user.user_assets
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

  def destroy
    user_asset = current_user.user_assets.find(params[:id])

    if user_asset.destroy
      redirect_to user_assets_path, notice: t("message.user_asset.destroy.success")
    else
      render_error(t("message.user_assets.destroy.failure"), :not_found)
    end
  end

  def update_simulation_data
    if current_user.simulation.update_user_asset_data!(current_user)
      redirect_to new_life_event_path, notice: t("message.simulation.update.success")
    else
      redirect_to user_assets_path, alert: t("message.simulation.update.failure")
    end
  end

  private

  def set_incomes
    @user_assets = current_user.user_assets
  end

  def user_asset_params
    params.require(:user_asset).permit(:person_type, :asset_type, :amount, :return_rate)
  end

  def render_error(message, status)
    flash.now[:alert] = message
    render :index, status: status
  end
end
