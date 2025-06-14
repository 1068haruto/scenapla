class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_latest_expense, only: [ :index, :edit, :update, :create, :destroy ]
  before_action :set_expense, only: [ :edit, :update, :destroy ]

  def index
    @expense = Expense.new
  end

  def create
    old_expense = current_user.expenses.last
    @expense = current_user.expenses.build(expense_params)
    @expense.simulation = current_user.simulation

    if @expense.save
      old_expense.destroy if old_expense.present? && old_expense.id != @expense.id
      redirect_to expenses_path, notice: t("message.expense.create.success")
    else
      render_error(@expense.errors.full_messages.join(", "), :unprocessable_entity)
    end
  end

  def edit
    if @expense
      render :index
    else
      render_error(t("message.expense.edit.failure"), :not_found)
    end
  end

  def update
    if @expense.update(expense_params)
      redirect_to expenses_path, notice: t("message.expense.update.success")
    else
      render_error(@expense.errors.full_messages.join(", "), :unprocessable_entity)
    end
  end

  def destroy
    if @expense.destroy
      redirect_to expenses_path, notice: t("message.expense.destroy.success")
    else
      render_error(t("message.expense.destroy.failure"), :not_found)
    end
  end

  private

  def set_latest_expense
    @latest_expense = current_user.expenses.last
  end

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:housing_expenses, :repayment_date, :living_expenses, :monthly_premiums, :other_expenses)
  end

  def render_error(message, status)
    flash.now[:alert] = message
    render :index, status: status
  end
end
