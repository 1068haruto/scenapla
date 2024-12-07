class Simulation < ApplicationRecord
  belongs_to :user
  has_many :incomes
  has_many :expenses
  has_many :user_assets
  has_many :life_events
  has_many :scenarios

  validates :user_id, presence: true

  # データを統合し、次年に収支を反映
  def merged_income_expense_event
    merged = merge_data(income_data, expense_data, real_life_event_data)

    # 前年の収支を次の年に反映
    merged.each_cons(2) do |previous, current|
      current["amount"] += previous["amount"]
    end

    merged
  end

  # income_dataの合計を計算
  def total_income
    income_data.sum { |entry| entry["amount"].to_f }
  end

  # expense_dataとreal_life_event_dataを統合して合計を計算
  def total_expense
    merge_data(expense_data, real_life_event_data).sum { |entry| entry["amount"].to_f }
  end

  # expensesテーブルの指定列を合計
  def total_expenses_sum
    expenses.sum(:housing_expense) + 
    expenses.sum(:living_expenses) + 
    expenses.sum(:monthly_premiums) + 
    expenses.sum(:other_expenses)
  end

  # total_balanceから不足年数を計算
  def calculate_shortage(total_balance)
    remaining_years = [70 - user.age, 0].max # 70歳までの残り年数
    (total_balance.abs / remaining_years).round(2)
  end

  private

  # データを統合し、同じdateでamountを合計
  def merge_data(*datasets)
    merged = datasets.flatten.group_by { |entry| entry["date"] }
    merged.map do |date, entries|
      {
        "date" => date,
        "amount" => entries.sum { |entry| entry["amount"].to_f }
      }
    end.sort_by { |entry| entry["date"] }
  end
end
