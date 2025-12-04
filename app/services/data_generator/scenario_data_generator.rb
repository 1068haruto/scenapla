module DataGenerator
  class ScenarioDataGenerator
    def initialize(user)
      @user = user
      @simulation = user.simulation
    end

    # Scenarioデータ生成-> Hash
    def call(event_data)
      # 生涯収入
      income = @simulation.income_data
      total_income = Formatter.sum_entries(income).round(1)

      # 生涯支出
      merged_expense_event = merge_data(@simulation.expense_data, event_data)
      total_expense = Formatter.sum_entries(merged_expense_event).round(1)

      # 生涯収支
      total_balance = (total_income + total_expense).round(1)

      # 収支シナリオ
      merged_income_expense_event = merge_data(income, merged_expense_event)
      merged_income_expense_event.each_cons(2) do |previous, current|
        current["amount"] = (current["amount"].to_d + previous["amount"].to_d).round(1)
      end
      balance_scenario = merged_income_expense_event

      # 取崩し
      withdrawal = 0
      if total_balance > 0
        monthly_expense = @simulation.expenses.sum(
          "housing_expenses + living_expenses + monthly_premiums + other_expenses"
        )
        if monthly_expense.to_d > 0
          withdrawal = (total_balance / monthly_expense.to_d).round(1)
        end
      end

      # 不足額
      shortage = 0
      remaining_years = Constants::AGE_LIMIT - @user.calculate_user_age
      if total_balance < 0 && remaining_years > 0
        shortage = (total_balance.abs / remaining_years.to_d).round(1)
      end

      {
        balance_scenario: balance_scenario,
        total_income: total_income,
        total_expense: total_expense,
        total_balance: total_balance,
        withdrawal: withdrawal,
        shortage: shortage
      }
    end

    private

    # 複数データのマージ-> Array
    def merge_data(*datasets)
      datasets = datasets.map { |dataset| dataset || [] }
      merged = datasets.flatten.group_by { |entry| entry["date"] }

      yearly_totals = merged.transform_values do |entries|
        Formatter.sum_entries(entries)
      end

      formatted_array = Formatter.format(yearly_totals)
      formatted_array.sort_by { |entry| entry["date"] }
    end
  end
end
