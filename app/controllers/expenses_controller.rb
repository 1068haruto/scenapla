class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_latest_expense, only: [ :index, :create, :edit, :update, :destroy ]
  before_action :set_expense_or_redirect, only: [ :edit, :update, :destroy ]

  def index
    @expense = Expense.new
  end

  def create
    oldExpense = current_user.expenses.last
    @expense = current_user.expenses.build(expense_params)
    @expense.simulation = current_user.simulation

    if @expense.save
      oldExpense.destroy if oldExpense.present? && oldExpense.id != @expense.id

      redirect_to expenses_path,
      notice: t("common.actions.create", model: "支出データ")
    else
      render_error(
        @expense.errors.full_messages.join,
        :unprocessable_entity
      )
    end
  end

  def edit
    render :index
  end

  def update
    if @expense.update(expense_params)
      redirect_to expenses_path,
      notice: t("common.actions.update", model: "支出データ")
    else
      render_error(
        @expense.errors.full_messages.join,
        :unprocessable_entity
      )
    end
  end

  def destroy
    if @expense.destroy
      redirect_to expenses_path,
      notice: t("common.actions.destroy", model: "支出データ")
    else
      render_error(
        t("common.actions.destroy_failed", model: "支出データ"),
        :unprocessable_entity
      )
    end
  end

  private

  def set_latest_expense
    @latest_expense = current_user.expenses.last
  end

  def set_expense_or_redirect
    @expense = current_user.expenses.find_by(id: params[:id])
    unless @expense
      redirect_to expenses_path,
      alert: t("common.actions.not_found", model: "支出データ")
    end
  end

  def expense_params
    params.require(:expense).permit(
      :housing_expenses,
      :repayment_date,
      :living_expenses,
      :monthly_premiums,
      :other_expenses
    )
  end
end
