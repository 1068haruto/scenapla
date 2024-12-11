class IncomesController < ApplicationController
  before_action :authenticate_user!

  def index
    @incomes = current_user.incomes
    @income = Income.new
  end

  def create
    @income = current_user.incomes.build(convert_retirement_date(income_params))
    @income.simulation = current_user.simulation

    if @income.save
      redirect_to incomes_path, notice: '収入データが追加されました'
    else
      render_create_error
    end
  end

  def destroy
    @income = Income.find(params[:id])

    if @income.destroy
      redirect_to incomes_path, notice: '収入データが削除されました'
    else
      redirect_to incomes_path, alert: '収入データの削除に失敗しました'
    end
  end

  def update_simulation_data
    # 各Incomeから収入データを集計
    all_income_data = current_user.incomes.flat_map(&:calculate_yearly_income_data)

    # 年ごとに収入を集計
    grouped_income_data = all_income_data.group_by { |data| data[:date] }.map do |year, records|
      { date: year, amount: records.sum { |record| record[:amount] } }
    end

    # シミュレーションデータを更新
    if current_user.simulation.update!(income_data: grouped_income_data)
      redirect_to expenses_path
    else
      redirect_to incomes_path, alert: 'シミュレーションデータの更新に失敗しました'
    end
  end

  private

  def income_params
    params.require(:income).permit(:person_type, :income, :retirement_date, :retirement_pay)
  end

  def convert_retirement_date(params)
    if params[:retirement_date].present?
      params[:retirement_date] = Date.new(params[:retirement_date].to_i, 1, 1)
    end
    params
  end

  def render_create_error
    @incomes = current_user.incomes
    flash.now[:error] = @income.errors.full_messages.join(", ")
    render :index, status: :unprocessable_entity
  end
end
