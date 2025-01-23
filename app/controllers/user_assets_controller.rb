class UserAssetsController < ApplicationController
  def index
    @user_assets = current_user.user_assets
    @user_asset = UserAsset.new
  end

  def create
    @user_asset = current_user.user_assets.build(user_asset_params)
    @user_asset.simulation = current_user.simulation

    if @user_asset.save
      redirect_to user_assets_path, notice: "資産データが追加されました"
    else
      @user_assets = current_user.user_assets # 保存済みの収入情報を再取得
      flash.now[:error] = @user_asset.errors.full_messages.join(", ")
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @user_asset = UserAsset.find(params[:id]) # 資産をIDで取得

    if @user_asset.destroy
      redirect_to user_assets_path, notice: "資産データを削除しました。"
    else
      redirect_to user_assets_path, alert: "資産データを削除できませんでした。"
    end
  end

  def update_simulation_data
    user_assets_data = UserAsset.calculate_user_assets(current_user)

    # Simulationモデルの該当データを更新
    simulation = Simulation.find_by(user: current_user)
    simulation.user_asset_data = user_assets_data

    if simulation.save
      redirect_to new_life_event_path, notice: "シミュレーションデータに保存しました。"
    else
      redirect_to user_assets_path, alert: "シミュレーションデータに保存できませんでした。"
    end
  end

  private

  def user_asset_params
    params.require(:user_asset).permit(:user_id, :simulation_id, :person_type, :asset_type, :amount, :return_rate)
  end
end
