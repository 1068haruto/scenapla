class ScenariosController < ApplicationController
  before_action :authenticate_user!

  def index
    @simulation = Simulation.find_by(user_id: current_user.id)
    @scenarios = Scenario.where(user_id: current_user.id) # 複数のシナリオを取得

    @asset_lifespan = @simulation.asset_lifespans.last # 最新の資産寿命データ

    if @asset_lifespan
      @lifespan_years = @asset_lifespan.lifespan_years
      @lifespan_months = @asset_lifespan.lifespan_months
    else
      @lifespan_years = nil
      @lifespan_months = nil
    end

    # 資産寿命データ　各支出を安全に取得(nilを0に変換)
    monthly_expenses = @simulation.expenses.sum(:housing_expense).to_f +
    @simulation.expenses.sum(:living_expenses).to_f +
    @simulation.expenses.sum(:monthly_premiums).to_f +
    @simulation.expenses.sum(:other_expenses).to_f
    # 必要なデータがない場合
    total_assets = @simulation.user_assets.sum(:amount)
    if total_assets <= 0 || monthly_expenses <= 0
      @asset_lifespan = nil
      @asset_lifespan_updated_at = nil # 資産寿命がない場合もnilを設定
    else
      @asset_lifespan = @simulation.asset_lifespans.last # 最新の資産寿命データを取得
      @asset_lifespan_updated_at = @asset_lifespan&.updated_at # nilの場合はnilが代入される
    end

    # 資産シナリオ
    user_assets = @simulation.user_assets.where(user_id: current_user.id)
    if user_assets.any?
      @asset_data = @simulation.user_asset_data&.map { |entry| [ entry["date"], entry["amount"] ] }&.to_h || {}
      @user_asset_data_updated_at = @simulation.updated_at
    else
      @asset_data = []
    end

    # 現実的シナリオ
    real_scenario = @scenarios.find { |scenario| scenario.scenario_type == "現実" }
    if real_scenario
      @real_updated_at = real_scenario.updated_at
      @real_balance_chart_data = real_scenario.balance_chart_data
      @real_total_income = real_scenario.total_income || 0
      @real_total_expense = real_scenario.total_expense || 0
      @real_total_balance = real_scenario.total_balance || 0
      @real_withdrawal = real_scenario.withdrawal || 0
      @real_shortage = real_scenario.shortage || 0
    else
      # 現実的シナリオが見つからなかった場合の処理
      @real_balance_chart_data = []
      @real_total_income = 0
      @real_total_expense = 0
      @real_total_balance = 0
      @real_withdrawal = 0
      @real_shortage = 0
    end

    # 理想的シナリオ
    ideal_scenario = @scenarios.find { |scenario| scenario.scenario_type == "理想" }
    events = LifeEvent.where(user_id: current_user.id)

    if ideal_scenario && events.any? { |event| event.event_type == "理想" }
      @ideal_updated_at = ideal_scenario.updated_at
      @ideal_balance_chart_data = ideal_scenario.balance_chart_data
      @ideal_total_income = ideal_scenario.total_income || 0
      @ideal_total_expense = ideal_scenario.total_expense || 0
      @ideal_total_balance = ideal_scenario.total_balance || 0
      @ideal_withdrawal = ideal_scenario.withdrawal || 0
      @ideal_shortage = ideal_scenario.shortage || 0
    else
      # 理想的シナリオが見つからなかった場合の処理
      @ideal_balance_chart_data = []
      @ideal_total_income = 0
      @ideal_total_expense = 0
      @ideal_total_balance = 0
      @ideal_withdrawal = 0
      @ideal_shortage = 0
    end
  end

  def update_scenarios
    success = current_user.scenarios.all?(&:update_scenario_data!)
    if success
      redirect_to scenarios_path, notice: "シナリオを更新しました。"
    else
      redirect_to scenarios_path, alert: "シナリオを更新できませんでした。"
    end
  end
end
