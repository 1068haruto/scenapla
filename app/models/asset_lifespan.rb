class AssetLifespan < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  validates :yearly_lifespans, presence: true

  # 資産寿命データの更新
  def self.update_lifespan_data!(simulation, yearly_lifespan, lifespan_years, lifespan_months)
    lifespan = simulation.asset_lifespans.find_or_initialize_by(user_id: simulation.user_id)
    lifespan.update!(
      user_id: simulation.user_id,
      yearly_lifespans: yearly_lifespan,
      lifespan_years: lifespan_years,
      lifespan_months: lifespan_months
    )
  end

  def user_asset_chart_data
    yearly_lifespans&.map { |year, amount| [year, amount.to_f] }&.to_h || {}
  end
end
