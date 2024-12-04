class SimulationsController < ApplicationController
  def update_scenario
    simulation = Simulation.find(params[:id])
    scenario_data = simulation.merged_data
  
    scenario = simulation.scenarios.update!(
      user_id: simulation.user_id,
      asset_scenario: scenario_data
    )
  
    redirect_to scenarios_path, notice: 'シナリオを作成しました。'
  rescue => e
    redirect_to scenarios_path, alert: "シナリオ作成中にエラーが発生しました: #{e.message}"
  end
end
