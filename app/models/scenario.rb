require 'bigdecimal'

class Scenario < ApplicationRecord
  include Constants

  belongs_to :user
  belongs_to :simulation

  enum scenario_type: { 現実: 0, 理想: 1 }

  validates :user_id, :simulation_id, presence: true

  # todo: n1、transaction、エラハン

  # 全scenario(現実, 理想)の更新-> boolean
  def self.update_scenarios(user)
    scenarios = user.scenarios
    simulation = user.simulation

    Scenario.transaction do
      scenarios.each do |scenario|
        if scenario.scenario_type == "現実"
          event_data = simulation.real_event_data
        else
          event_data = simulation.ideal_event_data
        end
        data = Scenario.generate_scenario(simulation, event_data)
        scenario.update!(data)
      end

      AssetLifespan.calculate_and_save_lifespan_data(simulation)
      true
    end
  rescue => e
    Rails.logger.error("更新失敗: #{e.message}")
    false
  end

  # scenarioの生成-> Hash
  def self.generate_scenario(simulation, event_data)
    # 生涯収入
    income = simulation.income_data
    total_income = income.sum(BigDecimal('0.0')) { |entry| entry["amount"].to_d }.round(1)

    # 生涯支出
    merged_expense_event = self.merge_data(simulation.expense_data, event_data)
    total_expense = merged_expense_event.sum(BigDecimal('0.0')) { |entry| entry["amount"].to_d }.round(1)

    # 生涯収支
    total_balance = total_income + total_expense

    # 収支シナリオ
    merged_income_expense_event = self.merge_data(income, merged_expense_event)
    merged_income_expense_event.each_cons(2) do |previous, current|  # 前年収支を次年に反映
      current["amount"] = (current["amount"].to_d + previous["amount"].to_d).round(1)
    end
    balance_scenario = merged_income_expense_event

    # 取崩し
    withdrawal = 0
    if total_balance > 0
      monthly_expense = simulation.expenses.sum(
        "housing_expenses + living_expenses + monthly_premiums + other_expenses"
      )
      if monthly_expense.to_d > 0 # ゼロ除算防止
        withdrawal = (total_balance / monthly_expense.to_d).round(1)
      else
        withdrawal = nil # または 0 などの適切な値
      end
    end

    # 不足額
    shortage = 0
    remaining_years = AGE_LIMIT - simulation.user.calculate_user_age # 70歳までの残年数
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

  # 複数データのマージ-> Array
  def self.merge_data(*datasets)
    datasets = datasets.map { |dataset| dataset || [] }
    merged = datasets.flatten.group_by { |entry| entry["date"] }

    yearly_totals = merged.transform_values do |entries|
      entries.sum(BigDecimal('0.0')) { |entry| entry["amount"].to_d }
    end

    formatted_array = FormatService.format(yearly_totals)
    formatted_array.sort_by { |entry| entry["date"] }
  end

  # (移動予定)
  def balance_chart_data
    balance_scenario.map { |entry| [ entry["date"], entry["amount"] ] }&.to_h || {}
  end
end