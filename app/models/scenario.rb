class Scenario < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum scenario_type: { 現実: '現実', 理想: '理想' }

  validates :scenario_type, presence: true, inclusion: { in: scenario_types.keys }
  validates :asset_scenario, presence: true
  validates :balance_scenario, presence: true
  validates :total_income, :total_expense, :total_balance, :withdrawal, :shortage, numericality: true, presence: true
end
