class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    @last_expense = current_user.expenses.last
    @expense = Expense.new
  end

  def create
    @expense = current_user.expenses.build(convert_repayment_date(expense_params))
    @expense.simulation = current_user.simulation

    if @expense.save
      @expense.update_simulation_expense_data(current_user)
      @last_expense = current_user.expenses.last
      respond_to_format
      # redirect_to assets_path
    else
      @last_expense = @expense
      render_create_error
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
