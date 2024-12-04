class Simulation < ApplicationRecord
  belongs_to :user
  has_many :incomes
  has_many :expenses
  has_many :user_assets
  has_many :life_events
  has_many :scenarios

  validates :user_id, presence: true

  def merged_data
    # income_dataとexpense_dataを統合
    income_expense = merge_data(income_data, expense_data)

    # income_expenseとuser_asset_dataを統合
    final_data = merge_data(income_expense, user_asset_data)

    # Chartkick用の形式に変換
    format_for_chartkick(final_data)
  end

  private

  # データを統合し、同じdateでamountを合計する
  def merge_data(data1, data2)
    merged = (data1 + data2).group_by { |entry| entry["date"] }
    merged.map do |date, entries|
      {
        "date" => date,
        "amount" => entries.sum { |entry| entry["amount"].to_f }
      }
    end
  end

  # Chartkickが期待する形式に変換
  def format_for_chartkick(data)
    data.map { |entry| [entry["date"], entry["amount"]] }.to_h
  end
end
