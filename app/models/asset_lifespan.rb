class AssetLifespan < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  validates :user_id, :simulation_id, presence: true
  validates :asset_lifespan_scenario, presence: true
  validates :lifespan_years, :lifespan_months, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # asset_lifespan_scenarioの生成->
  # (更新と分離、リファクタ予定)
  def self.calculate_and_save_lifespan_data(simulation)
    total_assets = simulation.user_assets.sum(:amount)
    monthly_expense = simulation.expenses.sum(
      "housing_expenses + living_expenses + monthly_premiums + other_expenses"
    )
    return if monthly_expense <= 0 # 月支出がなければスキップ

    remaining_asset = total_assets
    current_month = Date.today.month
    current_year = Date.today.year

    # 💡ハッシュの配列としてデータを格納に変更
    lifespan_scenario_array = []
    # 1年目(残り月分)
    remaining_months = 12 - current_month + 1
    lifespan_scenario_array << { "date" => current_year, "amount" => remaining_asset.round(1) }
    remaining_asset -= monthly_expense * remaining_months
    # 2年目以降(12ヶ月単位)
    next_year = current_year + 1
    annual_expense = monthly_expense * 12
    annual_expense_d = annual_expense.to_d
    while remaining_asset > -annual_expense_d
      lifespan_scenario_array << { "date" => next_year, "amount" => remaining_asset.round(1) }
      remaining_asset -= annual_expense_d
      next_year += 1
    end

    # 資産寿命を年と月に変換 (変更なし)
    total_months = (total_assets / monthly_expense).floor
    lifespan_years = total_months / 12
    lifespan_months = total_months % 12

    # 更新処理
    lifespan = simulation.asset_lifespans.find_or_initialize_by(user_id: simulation.user_id)
    lifespan.update!(
      user_id: simulation.user_id,
      asset_lifespan_scenario: lifespan_scenario_array,
      lifespan_years: lifespan_years,
      lifespan_months: lifespan_months
    )
  end
end
