class IncomesController < ApplicationController
  before_action :authenticate_user!

  def index
    @incomes = Income.all
    @income = Income.new
  end

  def create
    @income = current_user.incomes.build(convert_retirement_date(income_params))
    @income.simulation = current_user.simulation

    if @income.save
      update_simulation_data
      respond_to_format
    else
      render_create_error
    end
  end

  private

  # パラメータ変換
  def convert_retirement_date(params)
    if params[:retirement_date].present?
      # retirement_dateを年からDate型に変換
      params[:retirement_date] = Date.new(params[:retirement_date].to_i, 1, 1)
    end
    params
  end

  def income_params
    params.require(:income).permit(:person_type, :income, :retirement_date, :retirement_pay)
  end

  def update_simulation_data
    updated_data = calculate_income_data
    @income.simulation.update!(income_data: updated_data)
  end

  def calculate_income_data
    income_data = Hash.new(0)  # 年ごとの金額を集計するハッシュを初期化
    latest_income = current_user.incomes.order(created_at: :desc).first  # 最新の収入データを取得
  
    (Date.current.year..latest_income.retirement_date.year).each do |year|
      amount = latest_income.income.to_i * 12
      # 退職年には退職金を加える
      total_amount = year == latest_income.retirement_date.year ? amount + latest_income.retirement_pay.to_i : amount
      # 年ごとの金額を加算
      income_data[year] += total_amount
    end
  
    # ハッシュを配列に変換
    income_data.map do |year, total_amount|
      { date: year, amount: total_amount }
    end
  end

  def respond_to_format
    respond_to do |format|
      format.html { redirect_to incomes_path, notice: 'Income was successfully created.' }
      format.turbo_stream
    end
  end

  def render_create_error
    flash.now[:error] = @income.errors.full_messages.join(", ")
    @incomes = Income.all
    render :index
  end
end