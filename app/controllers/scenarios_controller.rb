class ScenariosController < ApplicationController
  before_action :authenticate_user!

  def index
    @simulation = current_user.simulation
    @scenarios = current_user.scenarios
    @asset_lifespan = current_user.asset_lifespans.last
    @incomes = current_user.incomes
    @expenses = current_user.expenses

    # 資産寿命シナリオ
    @lifespan_years = @asset_lifespan&.lifespan_years
    @lifespan_months = @asset_lifespan&.lifespan_months
    @lifespan_chart_data = @asset_lifespan&.user_asset_chart_data

    expense_totals = @simulation.expenses.pluck(:housing_expenses, :living_expenses, :monthly_premiums, :other_expenses)
    monthly_expenses = expense_totals.flatten.sum.to_f
    total_assets = @simulation.user_assets.sum(:amount)

    if total_assets <= 0 || monthly_expenses <= 0
      @asset_lifespan = nil
      @asset_lifespan_updated_at = nil
    else
      @asset_lifespan_updated_at = @asset_lifespan&.updated_at
    end

    # 現実的シナリオ
    real_scenario = @scenarios.find { |s| s.scenario_type == "現実" }
    @real_updated_at = real_scenario&.updated_at
    @real_balance_chart_data = real_scenario&.balance_chart_data || []
    @real_total_income = real_scenario&.total_income || 0
    @real_total_expense = real_scenario&.total_expense || 0
    @real_total_balance = real_scenario&.total_balance || 0
    @real_withdrawal = real_scenario&.withdrawal || 0
    @real_shortage = real_scenario&.shortage || 0

    # 理想的シナリオ
    ideal_scenario = @scenarios.find { |s| s.scenario_type == "理想" }
    events = current_user.life_events
    if ideal_scenario && events.any? { |event| event.event_type == "理想" }
      @ideal_updated_at = ideal_scenario.updated_at
      @ideal_balance_chart_data = ideal_scenario.balance_chart_data
      @ideal_total_income = ideal_scenario.total_income || 0
      @ideal_total_expense = ideal_scenario.total_expense || 0
      @ideal_total_balance = ideal_scenario.total_balance || 0
      @ideal_withdrawal = ideal_scenario.withdrawal || 0
      @ideal_shortage = ideal_scenario.shortage || 0
    else  # 理想シナリオが見つからない場合
      @ideal_balance_chart_data = []
      @ideal_total_income = 0
      @ideal_total_expense = 0
      @ideal_total_balance = 0
      @ideal_withdrawal = 0
      @ideal_shortage = 0
    end

    # 資産シナリオ
    @user_assets = current_user.user_assets
    @asset_data = @simulation.user_asset_chart_data
    @user_asset_data_updated_at = @simulation.updated_at if @asset_data.present?
  end

  def update_scenarios
    success = current_user.scenarios.all?(&:update_scenario_data!)

    if success
      redirect_to scenarios_path, notice: t("message.scenario.update.success")
    else
      redirect_to scenarios_path, alert: t("message.scenario.update.failure")
    end
  end
end
