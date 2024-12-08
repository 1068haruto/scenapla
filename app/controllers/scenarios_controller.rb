class ScenariosController < ApplicationController
  def index
    @simulation = Simulation.find_by(user_id: current_user.id)
    @scenarios = Scenario.where(user_id: current_user.id) # 複数のシナリオを取得

    # 資産シナリオ
    @asset_data = @simulation.user_asset_data.map { |entry| [entry["date"], entry["amount"]] }.to_h

    # 現実的シナリオ
    real_scenario = @scenarios.find { |scenario| scenario.scenario_type == '現実' }
    if real_scenario
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
    ideal_scenario = @scenarios.find { |scenario| scenario.scenario_type == '理想' }
    if ideal_scenario
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
end
