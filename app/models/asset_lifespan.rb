class AssetLifespan < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  validates :user_id, :simulation_id, presence: true
  validates :asset_lifespan_scenario, presence: true
  validates :lifespan_years, :lifespan_months, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.update_lifespan_data!(simulation, yearly_lifespan, lifespan_years, lifespan_months)
    lifespan = simulation.asset_lifespans.find_or_initialize_by(user_id: simulation.user_id)
    lifespan.update!(
      user_id: simulation.user_id,
      asset_lifespan_scenario: yearly_lifespan,
      lifespan_years: lifespan_years,
      lifespan_months: lifespan_months
    )
  end

  def user_asset_chart_data
    asset_lifespan_scenario&.map { |year, amount| [ year, amount.to_f ] }&.to_h || {}
  end
end
