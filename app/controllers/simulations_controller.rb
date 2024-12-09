class SimulationsController < ApplicationController
  def update_scenario
    simulation = Simulation.find(params[:id])

    # scenario_type: '現実' の更新処理
    update_scenario_data(simulation, '現実', simulation.real_life_event_data)

    # scenario_type: '理想' の更新処理
    update_scenario_data(simulation, '理想', simulation.ideal_life_event_data)

    # 資産寿命の計算と保存
    calculate_and_save_asset_lifespan(simulation)

    redirect_to scenarios_path, notice: 'シナリオを更新しました。'
  rescue ActiveRecord::RecordNotFound => e
    redirect_to scenarios_path, alert: "シナリオが見つかりませんでした: #{e.message}"
  rescue => e
    redirect_to scenarios_path, alert: "シナリオ更新中にエラーが発生しました: #{e.message}"
  end

  private

  # シナリオを更新する共通メソッド
  def update_scenario_data(simulation, scenario_type, life_event_data)
    # 各種データを計算
    merged_data = simulation.merged_income_expense_event(life_event_data)
    total_income = simulation.total_income

    # expense_data, real_life_event_data, ideal_life_event_data を統合して合計支出を算出
    total_expense = simulation.total_expense(
      simulation.expense_data,
      simulation.real_life_event_data,
      life_event_data
    )

    total_balance = total_income + total_expense

    # 該当するシナリオを取得
    scenario = simulation.scenarios.find_by!(scenario_type: scenario_type)

    # 必要なデータを計算
    total_expenses_sum = simulation.total_expenses_sum
    withdrawal = (total_balance > 0) ? (total_balance / total_expenses_sum).round(2) : 0
    shortage = (total_balance < 0) ? simulation.calculate_shortage(total_balance) : 0

    # シナリオを更新
    scenario.update!(
      balance_scenario: merged_data,
      total_income: total_income,
      total_expense: total_expense,
      total_balance: total_balance,
      withdrawal: withdrawal,
      shortage: shortage
    )
  end

  # 資産寿命を計算して保存するメソッド
  def calculate_and_save_asset_lifespan(simulation)
    total_assets = simulation.user_assets.sum(:amount)
    monthly_expenses = simulation.expenses.sum(:housing_expense) +
                       simulation.expenses.sum(:living_expenses) +
                       simulation.expenses.sum(:monthly_premiums) +
                       simulation.expenses.sum(:other_expenses)

    return if monthly_expenses <= 0 # 月次支出がない場合、計算をスキップ

    yearly_data = calculate_yearly_lifespan(total_assets, monthly_expenses)

    # `asset_lifespans`テーブルに保存
    simulation.asset_lifespans.create!(
      user_id: simulation.user_id,
      yearly_lifespans: yearly_data
    )
  end

  # 年ごとの資産寿命データを計算するヘルパーメソッド
  def calculate_yearly_lifespan(total_assets, monthly_expenses)
    yearly_data = {}
    remaining_assets = total_assets
    year = Date.today.year

    while remaining_assets > 0
      yearly_data[year] = remaining_assets
      remaining_assets -= (monthly_expenses * 12)
      year += 1
    end

    # 次の年の資産をそのまま格納する
    yearly_data[year] = remaining_assets

    yearly_data
  end
end
