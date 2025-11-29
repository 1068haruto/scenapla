module DataGenerator
  class AssetLifespanDataGenerator
    MONTHS_IN_A_YEAR = Constants::MONTHS_IN_A_YEAR
    MONTH_OFFSET_FOR_INCLUSION = Constants::MONTH_OFFSET_FOR_INCLUSION

    def initialize(user)
      @user = user
      @simulation = user.simulation
    end

    # AssetLifespanデータの生成-> Hash
    def call
      current_month = Date.today.month
      current_year = Date.today.year
      total_assets = @user.user_assets.sum(:amount)
      remaining_asset = total_assets.to_d
      monthly_expense = @user.expenses.sum(
        "housing_expenses + living_expenses + monthly_premiums + other_expenses"
      )
      return if monthly_expense.to_d <= 0 # 月支出が0以下なら、nilでreturn

      # 資産寿命シナリオ
      lifespan_scenario = []
      # 1年目(残り月分)
      remaining_months = MONTHS_IN_A_YEAR - current_month + MONTH_OFFSET_FOR_INCLUSION
      lifespan_scenario << { "date" => current_year, "amount" => remaining_asset.round(1) }
      remaining_asset -= monthly_expense.to_d * remaining_months

      # 2年目以降(12ヶ月単位)
      next_year = current_year + 1
      annual_expense = (monthly_expense.to_d * MONTHS_IN_A_YEAR).to_d
      while remaining_asset > -annual_expense
        lifespan_scenario << { "date" => next_year, "amount" => remaining_asset.round(1) }
        remaining_asset -= annual_expense
        next_year += 1
      end

      # 資産寿命の年と月
      total_months = (total_assets.to_d / monthly_expense.to_d).floor
      lifespan_years = total_months / MONTHS_IN_A_YEAR
      lifespan_months = total_months % MONTHS_IN_A_YEAR

      {
        user_id: @user.id,
        simulation_id: @simulation.id,
        asset_lifespan_scenario: lifespan_scenario,
        lifespan_years: lifespan_years,
        lifespan_months: lifespan_months
      }
    end
  end
end
