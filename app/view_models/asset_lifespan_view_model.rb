class AssetLifespanViewModel
  def initialize(asset_lifespan, simulation)
    @asset_lifespan = asset_lifespan
    @simulation = simulation
  end

  def show?
    @asset_lifespan.present? && @asset_lifespan.asset_lifespan_scenario.present?
  end

  def lifespan_years
    @asset_lifespan&.lifespan_years
  end

  def lifespan_months
    @asset_lifespan&.lifespan_months
  end

  def lifespan_chart_data
    @lifespan_chart_data ||= Formatter.to_chart_hash(@asset_lifespan&.asset_lifespan_scenario)
  end

  def updated_at
    @updated_at ||= begin
      total_assets = @simulation.user_assets.sum(:amount)
      expense_totals = @simulation.expenses.pluck(
        :housing_expenses, :living_expenses, :monthly_premiums, :other_expenses
      )
      monthly_expenses = expense_totals.flatten.sum.to_f

      if total_assets <= 0 || monthly_expenses <= 0
        nil
      else
        @asset_lifespan&.updated_at
      end
    end
  end
end
