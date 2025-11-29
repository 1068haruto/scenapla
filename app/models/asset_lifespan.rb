class AssetLifespan < ApplicationRecord
  include Constants

  belongs_to :user
  belongs_to :simulation

  validates :user_id, :simulation_id, presence: true
  validates :asset_lifespan_scenario, presence: true
  validates :lifespan_years, :lifespan_months,
              presence: true, numericality: { greater_than_or_equal_to: 0 }
end
