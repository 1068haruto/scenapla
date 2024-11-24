class Scenario < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum scenario_type: { 現実: '現実', 理想: '理想' }

  validates :user_id, :simulation_id, presence: true
end
