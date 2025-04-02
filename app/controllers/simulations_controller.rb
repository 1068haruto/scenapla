class SimulationsController < ApplicationController
  before_action :authenticate_user!

  def update_income_data
    return redirect_to incomes_path, alert: t("message.simulation.update.failure") unless current_user.simulation

    income_data = Income.generate_income_data_for(current_user)
    if current_user.simulation.update!(income_data: income_data)
      redirect_to expenses_path, notice: t("message.simulation.update.success")
    else
      redirect_to incomes_path, alert: t("message.simulation.update.failure")
    end
  end

	def update_expense_data
    return redirect_to expenses_path, alert: t("message.simulation.update.failure") unless current_user.simulation

		expense_data = Expense.generate_expense_data_for(current_user)
    if current_user.simulation.update!(expense_data: expense_data)
      redirect_to user_assets_path, notice: t("message.simulation.update.success")
    else
      redirect_to expenses_path, alert: t("message.simulation.update.failure")
    end
  end
end
