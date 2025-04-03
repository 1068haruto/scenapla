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
      render_error(@expense.errors.full_messages.join(", "), :unprocessable_entity)
    end
  end

  def destroy
    expense = current_user.expenses.find(params[:id])

    if expense.destroy
      redirect_to expenses_path, notice: t("message.expense.destroy.success")
    else
      render_error(t("message.expense.destroy.failure"), :not_found)
    end
  end

  private

  def set_latest_expense
    @latest_expense = current_user.expenses.last
  end

  def expense_params
    params.require(:expense).permit(:housing_expenses, :repayment_date, :living_expenses, :monthly_premiums, :other_expenses)
  end

  def render_error(message, status)
    flash.now[:alert] = message
    render :index, status: status
  end
end
