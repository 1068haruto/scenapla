class AssetScenarioViewModel
  def initialize(simulation, user_assets)
    @simulation = simulation
    @user_assets = user_assets
  end

  def show?
    !asset_data.empty? && @user_assets.any?
  end

  def asset_data
    @asset_data ||= Formatter.to_chart_hash(@simulation&.user_asset_data)
  end

  def updated_at
    @simulation.updated_at if asset_data.present?
  end
end
