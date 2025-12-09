class BalanceScenarioViewModel
  def initialize(scenario:, incomes:, expenses:)
    @scenario = scenario
    @incomes = incomes
    @expenses = expenses
  end

  def show?
    @scenario.present? && !balance_chart_data.empty? && @incomes.any? && @expenses.any?
  end

  def updated_at
    @scenario&.updated_at
  end

  def balance_chart_data
    @balance_chart_data ||= if @scenario.nil?
      []
    else
      Formatter.to_chart_hash(@scenario&.balance_scenario)
    end
  end

  def total_income
    @scenario&.total_income || 0
  end

  def total_expense
    @scenario&.total_expense || 0
  end

  def total_balance
    @scenario&.total_balance || 0
  end

  def withdrawal
    @scenario&.withdrawal || 0
  end

  def shortage
    @scenario&.shortage || 0
  end
end
