class SimulationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_simulation

  def update_income_data
    income_data = Income.generate_income_data_for(current_user)

    if @simulation.update(income_data: income_data)
      update_success(expenses_path)
    else
      update_failure(incomes_path)
    end
  end

  def update_expense_data
    expense_data = Expense.generate_expense_data_for(current_user)

    if @simulation.update(expense_data: expense_data)
      update_success(user_assets_path)
    else
      update_failure(expenses_path)
    end
  end

  def update_user_asset_data
    user_asset_data = UserAsset.generate_user_asset_data_for(current_user)

    if @simulation.update(user_asset_data: user_asset_data)
      update_success(new_life_event_path)
    else
      update_failure(user_assets_path)
    end
  end

  def update_life_event_data
    life_event_data = LifeEvent.generate_life_event_data_for(current_user)

    if @simulation.update(
      real_event_data: life_event_data[:real_event_data].presence,
      ideal_event_data: life_event_data[:ideal_event_data].presence
    )
      update_success(scenarios_path)
    else
      update_failure(new_life_event_path)
    end
  end

  private

  def set_simulation
    @simulation = current_user.simulation
  end

  def update_success(path)
    redirect_to path, notice: t("message.simulation.update.success")
  end

  def update_failure(path)
    redirect_to path, alert: t("message.simulation.update.failure")
  end
end
