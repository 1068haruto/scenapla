module DataUpdater
  class DualDataUpdater
    def initialize(user)
      @user = user
    end

    # ScenarioとAssetLifespanの同時更新呼び出し-> Boolean
    def call
      ActiveRecord::Base.transaction do
        ScenarioDataUpdater.new(@user).call
        AssetLifespanDataUpdater.new(@user).call
        true
      end
    rescue => e
      Rails.logger.error("一括更新失敗。#{e.message}")
      false
    end
  end
end
