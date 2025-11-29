class AssetLifespan < ApplicationRecord
  include Constants

  belongs_to :user
  belongs_to :simulation

  validates :user_id, :simulation_id, presence: true
  validates :asset_lifespan_scenario, presence: true
  validates :lifespan_years, :lifespan_months,
              presence: true, numericality: { greater_than_or_equal_to: 0 }

  # asset_lifespanの更新-> void
  def self.update_asset_lifespan(user)
    simulation = user.simulation
    asset_lifespan = user.asset_lifespans.find_or_initialize_by(simulation_id: simulation.id)
    data = generate_asset_lifespan(user)
    asset_lifespan.update!(data)
  end

  # asset_lifespanの生成-> Hash
  def self.generate_asset_lifespan(user)
    total_assets = user.user_assets.sum(:amount)
    monthly_expense = user.expenses.sum(
      "housing_expenses + living_expenses + monthly_premiums + other_expenses"
    )
    return if monthly_expense <= 0
    remaining_asset = total_assets
    current_month = Date.today.month
    current_year = Date.today.year

    lifespan_scenario = []
    # 1年目(残り月分)
    remaining_months = MONTHS_IN_A_YEAR - current_month + MONTH_OFFSET_FOR_INCLUSION
    lifespan_scenario << { "date" => current_year, "amount" => remaining_asset.round(1) }
    remaining_asset -= monthly_expense * remaining_months
    # 2年目以降(12ヶ月単位)
    next_year = current_year + 1
    annual_expense = (monthly_expense * MONTHS_IN_A_YEAR).to_d
    while remaining_asset > -annual_expense
      lifespan_scenario << { "date" => next_year, "amount" => remaining_asset.round(1) }
      remaining_asset -= annual_expense
      next_year += 1
    end

    # 資産寿命の年と月
    total_months = (total_assets / monthly_expense).floor
    lifespan_years = total_months / MONTHS_IN_A_YEAR
    lifespan_months = total_months % MONTHS_IN_A_YEAR

    {
      user_id: user.id,
      simulation_id: user.simulation.id,
      asset_lifespan_scenario: lifespan_scenario,
      lifespan_years: lifespan_years,
      lifespan_months: lifespan_months
    }
  end
end
