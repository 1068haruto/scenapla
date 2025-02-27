class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_latest_expense, only: [ :index, :create_or_update ]

  def index
    @expense = Expense.new
  end

  def create_or_update
    @expense = current_user.expenses.last || current_user.expenses.build

    @expense.assign_attributes(expense_params)
    @expense.simulation ||= current_user.simulation # 未設定の場合のみ

    if @expense.save
      redirect_to expenses_path, notice: t("message.expense.create_or_update.success")
    else
      render_error
    end
  end

  def update_simulation_data
    if current_user.simulation.update_expense_data!(current_user)
      redirect_to user_assets_path, notice: t("message.simulation.update.success")
    else
      redirect_to expenses_path, alert: t("message.simulation.update.failure")
    end
  end

  private

  def set_latest_expense
    @latest_expense = current_user.expenses.last
  end

  def expense_params
    params.require(:expense).permit(:housing_expenses, :repayment_date, :living_expenses, :monthly_premiums, :other_expenses)
  end

  def render_error
    flash.now[:error] = @expense.errors.full_messages.join(", ")
    render :index, status: :unprocessable_entity
  end
end
