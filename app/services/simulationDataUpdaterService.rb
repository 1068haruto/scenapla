class SimulationDataUpdaterService
  attr_reader :user, :simulation

  def initialize(user)
    @user = user
    @simulation = user.simulation
  end

  # income_data
  def update_income
    income_data = Income.generate_income_data(user)
    simulation.update(income_data: income_data)
  end

  # expense_data
  def update_expense
    expense_data = Expense.generate_expense_data(user)
    simulation.update(expense_data: expense_data)
  end

  # user_asset_data
  def update_user_asset
    user_asset_data = UserAsset.generate_user_asset_data(user)
    simulation.update(user_asset_data: user_asset_data)
  end

  # life_event_data
  def update_life_event
    life_event_data = LifeEvent.generate_life_event_data(user)
    simulation.update(
      real_event_data: life_event_data[:real_event_data].presence,
      ideal_event_data: life_event_data[:ideal_event_data].presence
    )
  end
end