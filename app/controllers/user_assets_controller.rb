class UserAssetsController < AfterBaseController
  before_action :set_user_assets, only: [ :index, :create, :edit, :update, :destroy ]
  before_action :set_user_asset_or_redirect, only: [ :edit, :update, :destroy ]

  def index
    @user_asset = UserAsset.new
  end

  def create
    @user_asset = current_user.user_assets.build(user_asset_params)
    @user_asset.simulation = current_user.simulation

    if @user_asset.save
      redirect_to user_assets_path,
      notice: t("common.actions.create", data: ASSET_INFO)
    else
      render_error(
        @user_asset.errors.full_messages.join,
        :unprocessable_entity
      )
    end
  end

  def edit
    render :index
  end

  def update
    if @user_asset.update(user_asset_params)
      redirect_to user_assets_path,
      notice: t("common.actions.update", data: ASSET_INFO)
    else
      render_error(
        @user_asset.errors.full_messages.join,
        :unprocessable_entity
      )
    end
  end

  def destroy
    if @user_asset.destroy
      redirect_to user_assets_path,
      notice: t("common.actions.destroy", data: ASSET_INFO)
    else
      render_error(
        t("common.actions.destroy_failed", data: ASSET_INFO),
        :unprocessable_entity
      )
    end
  end

  private

  def set_user_assets
    @user_assets = current_user.user_assets
  end

  def set_user_asset_or_redirect
    @user_asset = current_user.user_assets.find_by(id: params[:id])
    unless @user_asset
      redirect_to user_assets_path,
      alert: t("common.actions.not_found", data: ASSET_INFO)
    end
  end

  def user_asset_params
    params.require(:user_asset).permit(
      :person_type,
      :asset_type,
      :amount, :return_rate
    )
  end
end
