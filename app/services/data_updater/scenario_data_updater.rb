module DataUpdater
  class ScenarioDataUpdater
    def initialize(user)
      @user = user
      @simulation = user.simulation
      @generator = DataGenerator::ScenarioDataGenerator.new(user)
    end

    # Scenarioデータ（現実, 理想）の更新-> Boolean
    def call
      scenarios = @user.scenarios

      scenarios.each do |scenario|
        if scenario.scenario_type == "現実"
          event_data = @simulation.real_event_data
        else
          event_data = @simulation.ideal_event_data
        end

        data = @generator.call(event_data)
        scenario.update!(data)
      end
      true
    end
  end
end
