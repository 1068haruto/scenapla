class IncomesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_income, only: [:destroy]

  def index
    @incomes = current_user.incomes
    @income = Income.new
  end

  def create
    @income = current_user.incomes.build(income_params)
    @income.simulation = current_user.simulation

    if @income.save
      redirect_to incomes_path, notice: '収入データを追加しました'
    else
      render_create_error
    end
  end

  def destroy
    if @income.destroy
      redirect_to incomes_path, notice: '収入データを削除しました。'
    else
      redirect_to incomes_path, alert: '収入データを削除できませんでした。'
    end
  end

  def update_simulation_data
    # Incomeから全ての収入データを取得し、それぞれを配列にする
    all_income_data = current_user.incomes.flat_map(&:calculate_yearly_income_data)

    # ハッシュ配列に整形された全ての収入データを、年毎に金額を集計して統合する
    grouped_income_data = all_income_data.group_by { |data| data[:date] }.map do |year, records|
      { date: year, amount: records.sum { |record| record[:amount] } }
    end

    # シミュレーションデータを更新
    if current_user.simulation.update!(income_data: grouped_income_data)
      redirect_to expenses_path, notice: 'シミュレーションデータに保存しました。'
    else
      redirect_to incomes_path, alert: 'シミュレーションデータに保存できませんでした。'
    end
  end

  private

  def income_params
    params.require(:income).permit(:person_type, :income, :retirement_date, :retirement_pay)
  end

  def set_income
    @income = current_user.incomes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to incomes_path, alert: '収入データが見つかりません'
  end

  def render_create_error
    @incomes = current_user.incomes
    flash.now[:error] = @income.errors.full_messages.join(", ")
    render :index, status: :unprocessable_entity
  end
end
