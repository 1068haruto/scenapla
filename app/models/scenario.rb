class Scenario < ApplicationRecord
  include Constants

  belongs_to :user
  belongs_to :simulation

  enum scenario_type: ApplicationEnums::SCENARIO_TYPES

  validates :user_id, :simulation_id, presence: true
end
