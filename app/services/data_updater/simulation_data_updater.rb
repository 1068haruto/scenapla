module DataUpdater
  class SimulationDataUpdater
    attr_reader :user, :simulation

    def initialize(user)
      @user = user
      @simulation = user.simulation
    end

    # income_data生成呼び出し&更新-> Boolean
    def update_income
      income_data = DataGenerator::IncomeDataGenerator.new(user).call
      simulation.update(income_data: income_data)
    end

    # expense_data生成呼び出し&更新-> Boolean
    def update_expense
      expense_data = DataGenerator::ExpenseDataGenerator.new(user).call
      simulation.update(expense_data: expense_data)
    end

    # user_asset_data生成呼び出し&更新-> Boolean
    def update_user_asset
      user_asset_data = DataGenerator::UserAssetDataGenerator.new(user).call
      simulation.update(user_asset_data: user_asset_data)
    end

    # life_event_data生成呼び出し&更新-> Boolean
    def update_life_event
      life_event_data = DataGenerator::LifeEventDataGenerator.new(user).call
      simulation.update(
        real_event_data: life_event_data[:real_event_data].presence,
        ideal_event_data: life_event_data[:ideal_event_data].presence
      )
    end
  end
end
