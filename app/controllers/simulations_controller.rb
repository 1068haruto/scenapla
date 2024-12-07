class SimulationsController < ApplicationController
  def update_scenario
    simulation = Simulation.find(params[:id])

    # 各種データを計算
    merged_data = simulation.merged_income_expense_event
    total_income = simulation.total_income
    total_expense = simulation.total_expense

    # `scenario_type: '現実'` のデータを取得
    scenario = simulation.scenarios.find_by!(scenario_type: '現実')

    # 該当するシナリオを更新
    scenario.update!(
      balance_scenario: merged_data,
      total_income: total_income,
      total_expense: total_expense
    )

    redirect_to scenarios_path, notice: 'シナリオを更新しました。'
  rescue ActiveRecord::RecordNotFound
    redirect_to scenarios_path, alert: "現実のシナリオが見つかりませんでした。"
  rescue => e
    redirect_to scenarios_path, alert: "シナリオ更新中にエラーが発生しました: #{e.message}"
  end
end
