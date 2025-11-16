class Scenario < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum scenario_type: { 現実: 0, 理想: 1 }

  validates :user_id, :simulation_id, presence: true

  # scenario_dataの更新->
  # (統合 & リファクタ予定)
  def update_scenario_data!
    life_event_data = (scenario_type == "現実") ? simulation.real_event_data : simulation.ideal_event_data
    calculated_data = Scenario.generate_scenario_data(simulation, life_event_data)
    update!(calculated_data)

  rescue StandardError => e
    Rails.logger.error("シナリオ更新エラー: #{e.message}")
    false
  end

  # scenario_dataの生成->
  # (後に統合 & リファクタ予定)
  def self.generate_scenario_data(simulation, life_event_data)
    # 収支シナリオ
    merged = self.merge_data(
      simulation.income_data, simulation.expense_data, life_event_data
    )
    merged.each_cons(2) do |previous, current|  # 前年収支を次年に反映
      current[:amount] = (current[:amount] + previous[:amount]).round(1)
    end
    balance_scenario = merged

    # 合計収入
    total_income_data = simulation.income_data
    total_income = total_income_data.sum { |entry| entry[:amount].to_f }.round(1)

    # 合計支出
    datasets = [ simulation.expense_data, life_event_data ]
    merged_data = self.merge_data(*datasets)
    total_expense = merged_data.sum { |entry| entry[:amount].to_f }.round(1)

    # 合計収支
    total_balance = total_income + total_expense

    # 取崩し
    withdrawal = 0
    if total_balance > 0
      monthly_expense_total = simulation.expenses.sum(
        "housing_expenses + living_expenses + monthly_premiums + other_expenses"
      )
      withdrawal = (total_balance / monthly_expense_total).round(1)
    end

    # 不足額
    shortage = 0
    remaining_years = 70 - simulation.user.calculate_user_age # 70歳までの残年数
    if total_balance < 0 && remaining_years > 0
      shortage = (total_balance.abs / remaining_years.to_f).round(1)
    end

    AssetLifespan.calculate_and_save_lifespan_data(simulation) # 移動予定

    {
      balance_scenario: balance_scenario,
      total_income: total_income,
      total_expense: total_expense,
      total_balance: total_balance,
      withdrawal: withdrawal,
      shortage: shortage
    }
  end

  def self.merge_data(*datasets)
    datasets = datasets.map { |dataset| dataset || [] }
    merged = datasets.flatten.group_by { |entry| entry[:date] }

    yearly_totals = merged.transform_values do |entries|
      entries.sum { |entry| entry[:amount].to_f }
    end
    formatted_array = FormatService.format(yearly_totals)

    formatted_array.sort_by { |entry| entry[:date] }
  end

  # (移動予定)
  def balance_chart_data
    balance_scenario.map { |entry| [ entry["date"], entry["amount"] ] }&.to_h || {}
  end
end
