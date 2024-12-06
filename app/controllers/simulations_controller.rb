class SimulationsController < ApplicationController
  def update_scenario
    simulation = Simulation.find(params[:id])

    # 各種データを計算
    merged_data = simulation.merged_income_expense_event
    total_income = simulation.total_income
    total_expense = simulation.total_expense

    # シナリオテーブルの更新
    scenario = simulation.scenarios.update!(
      user_id: simulation.user_id,
      scenario_type: '現実', # 注意点2
      balance_scenario: merged_data, # 注意点1・3
      total_income: total_income, # ②
      total_expense: total_expense # ③
    )

    redirect_to scenarios_path, notice: 'シナリオを更新しました。'
  rescue => e
    redirect_to scenarios_path, alert: "シナリオ更新中にエラーが発生しました: #{e.message}"
  end
end
