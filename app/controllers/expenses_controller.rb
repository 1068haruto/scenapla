class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    @last_expense = current_user.expenses.last
    @expense = Expense.new
  end

  def create_or_update
    # ユーザーの最新のexpenseを取得
    @expense = current_user.expenses.last || current_user.expenses.build

    # 新しいパラメータを反映
    @expense.assign_attributes(convert_repayment_date(expense_params))
    @expense.simulation = current_user.simulation

    if @expense.save
      respond_to_format
      @last_expense = current_user.expenses.last

    else
      @last_expense = @expense
      render_create_error
    end
  end

  def update_simulation_data
    expense = current_user.expenses.find(params[:id])
    if expense.update_simulation_data(current_user)
      redirect_to expenses_path, notice: 'シミュレーションデータが更新されました。'
    else
      redirect_to expenses_path, alert: 'シミュレーションデータの更新に失敗しました。'
    end
  end

  private

  def expense_params
    params.require(:expense).permit(:housing_expense, :repayment_date, :living_expenses, :monthly_premiums, :other_expenses)
  end

  def convert_repayment_date(params)
    if params[:repayment_date].present?
      params[:repayment_date] = Date.new(params[:repayment_date].to_i, 1, 1)
    end
    params
  end

  def respond_to_format
    respond_to do |format|
      format.html { redirect_to expenses_path, notice: '費用が保存されました。' }
      format.turbo_stream
    end
  end

  def render_create_error
    flash.now[:error] = @expense.errors.full_messages.join(", ")
    render :index
  end
end
