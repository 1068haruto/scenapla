class Scenario < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum scenario_type: { 現実: "現実", 理想: "理想" }

  validates :user_id, :simulation_id, presence: true

  # Chartkick用データ形式を返す
  def balance_chart_data
    balance_scenario.map { |entry| [ entry["date"], entry["amount"] ] }.to_h
  end
end
