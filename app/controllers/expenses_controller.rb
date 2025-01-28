class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    @latest_expense = current_user.expenses.includes(:simulation).last
    @expense = Expense.new
  end

  def create_or_update
    # ユーザーの最新のexpenseを取得
    @expense = current_user.expenses.last || current_user.expenses.build

    # 新しいパラメータを反映
    @expense.assign_attributes(expense_params)
    @expense.simulation = current_user.simulation

    if @expense.save
      redirect_to expenses_path, notice: "支出データを追加しました"
    else
      @latest_expense = @expense
      render_create_error
    end
  end

  def update_simulation_data
    if current_user.simulation.update_expense_data!(current_user)
      redirect_to user_assets_path, notice: "シミュレーションデータに保存しました"
    else
      redirect_to expenses_path, alert: "シミュレーションデータに保存できませんでした"
    end
  end

  private

  def expense_params
    params.require(:expense).permit(:housing_expense, :repayment_date, :living_expenses, :monthly_premiums, :other_expenses)
  end

  def render_create_error
    flash.now[:error] = @expense.errors.full_messages.join(", ")
    render :index, status: :unprocessable_entity
  end
end
