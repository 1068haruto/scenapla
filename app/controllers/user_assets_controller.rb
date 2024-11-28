class UserAssetsController < ApplicationController
  def index
    @user_asset = UserAsset.new # 新しいインスタンスを作成する
    @user_assets = UserAsset.all # インスタンスのリストも取得しているか確認
  end

  def create
    @user_asset = current_user.user_assets.build(user_asset_params)
    @user_asset.simulation = current_user.simulation

    if @user_asset.save
      respond_to_format
    else
      render :index # エラーがあった場合は新規作成フォームを再表示
    end
  end

  def destroy
    @user_asset = UserAsset.find(params[:id]) # 資産をIDで取得

    if @user_asset.destroy
      respond_to_format_destroy
    else
      redirect_to user_assets_path, alert: '資産の削除に失敗しました。'
    end
  end

  private

  def user_asset_params
    params.require(:user_asset).permit(:user_id, :simulation_id, :person_type, :asset_type, :amount, :return_rate)
  end

  def respond_to_format
    respond_to do |format|
      format.html { redirect_to user_assets_path, notice: '資産が保存されました。' }
      format.turbo_stream
    end
  end

  def respond_to_format_destroy
    respond_to do |format|
      format.html { redirect_to user_assets_path, notice: '資産が削除されました。' }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@user_asset) }
      #format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@user_asset)) }
    end
  end
end
