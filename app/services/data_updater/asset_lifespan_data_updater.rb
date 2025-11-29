module DataUpdater
  class AssetLifespanDataUpdater
    def initialize(user)
      @user = user
      @simulation = user.simulation
      @generator = DataGenerator::AssetLifespanDataGenerator.new(user)
    end

    # asset_lifespanの更新-> Boolean
    def call
      asset_lifespan = @user.asset_lifespans.find_or_initialize_by(simulation_id: @simulation.id)

      # AssetLifespanは更新せず、Scenarioのみ更新する場合があるため、
      # dataがnilなら更新前にtrueでreturnし、正常終了を伝える
      data = @generator.call
      return true unless data
      asset_lifespan.update!(data)
      true
    end
  end
end
