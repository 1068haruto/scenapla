class DualUpdaterService
  def initialize(user)
    @user = user
  end

  # ScenarioとAssetLifespanの更新 -> boolean
  def call
    ActiveRecord::Base.transaction do
      Scenario.update_scenarios(@user)
      AssetLifespan.update_asset_lifespan(@user)
      true
    end
  rescue => e
    Rails.logger.error("一括更新失敗。user_id: #{@user.id}: #{e.message}")
    false
  end
end
