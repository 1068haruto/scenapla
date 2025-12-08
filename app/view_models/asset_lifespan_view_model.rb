class AssetLifespanViewModel
  def initialize(asset_lifespan, simulation)
    @asset_lifespan = asset_lifespan
    @simulation = simulation
    setup_data
  end

  def show?
    @asset_lifespan.present? && @asset_lifespan.asset_lifespan_scenario.present?
  end

  def lifespan_years
    @lifespan_years
  end

  def lifespan_months
    @lifespan_months
  end

  def lifespan_chart_data
    @lifespan_chart_data
  end

  def updated_at
    @asset_lifespan_updated_at
  end

  private

  def setup_data
    @lifespan_years = @asset_lifespan&.lifespan_years
    @lifespan_months = @asset_lifespan&.lifespan_months
    @lifespan_chart_data = Formatter.to_chart_hash(@asset_lifespan&.asset_lifespan_scenario)

    expense_totals = @simulation.expenses.pluck(
      :housing_expenses, :living_expenses, :monthly_premiums, :other_expenses
    )

    total_assets = @simulation.user_assets.sum(:amount)
    monthly_expenses = expense_totals.flatten.sum.to_f
    if total_assets <= 0 || monthly_expenses <= 0
      @asset_lifespan_updated_at = nil
    else
      @asset_lifespan_updated_at = @asset_lifespan&.updated_at
    end
  end
end
