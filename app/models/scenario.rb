class Scenario < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum scenario_type: { 現実: "現実", 理想: "理想" }

  validates :user_id, :simulation_id, presence: true

  # Chart用に整形
  def balance_chart_data
    balance_scenario.map { |entry| [ entry["date"], entry["amount"] ] }&.to_h || {}
  end


  # シナリオ更新
  def update_scenario_data!
    life_event_data = (scenario_type == "現実") ? simulation.real_event_data : simulation.ideal_event_data
    calculated_data = Simulation.calculate_scenario_data(simulation, life_event_data)
    update!(calculated_data)

  rescue StandardError => e
    Rails.logger.error("シナリオ更新エラー: #{e.message}")
    false
  end
end
