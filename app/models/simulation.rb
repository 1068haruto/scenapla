class Simulation < ApplicationRecord
  belongs_to :user
  has_many :incomes, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :user_assets, dependent: :destroy
  has_many :life_events, dependent: :destroy
  has_many :scenarios, dependent: :destroy
  has_many :asset_lifespans, dependent: :destroy

  validates :user_id, presence: true

  # 収入
  def update_income_data!(user)
    income_data = Income.generate_income_data_for(user)
    update!(income_data: income_data)
  end

  # 支出
  def update_expense_data!(user)
    expense_data = Expense.generate_expense_data_for(user)
    update!(expense_data: expense_data)
  end

  # 資産
  def update_user_asset_data!(user)
    user_asset_data = UserAsset.generate_user_asset_data_for(user)
    update!(user_asset_data: user_asset_data)
  end

  # ライフイベント
  def update_life_event_data!(user)
    life_event_data = LifeEvent.generate_life_event_data_for(user)
    update!(
      real_life_event_data: life_event_data[:real_life_event_data].presence,
      ideal_life_event_data: life_event_data[:ideal_life_event_data].presence
    )
  end

  def self.update_simulation(simulation_id, real_data, ideal_data)
    simulation = Simulation.find(simulation_id)
    simulation.update_user_asset_data!(real_data, ideal_data)
  end


  # データを統合し、次年に収支を反映（引数として life_event_data を受け取る）
  def merged_income_expense_event(life_event_data)
    merged = merge_data(income_data, expense_data, life_event_data)

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

  # 合計支出を計算（複数のデータセットを受け取る）
  def total_expense(*datasets)
    # データセットを統合して合計金額を算出
    merge_data(*datasets).sum { |entry| entry["amount"].to_f }
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
    remaining_years = [ 70 - user.calculate_user_age, 0 ].max # 70歳までの残り年数
    (total_balance.abs / remaining_years).round(2)
  end

  private

  # データを統合し、同じdateでamountを合計
  def merge_data(*datasets)
    # nil のデータセットを空配列に変換
    datasets = datasets.map { |dataset| dataset || [] }

    merged = datasets.flatten.group_by { |entry| entry["date"] }
    merged.map do |date, entries|
      {
        "date" => date,
        "amount" => entries.sum { |entry| entry["amount"].to_f }
      }
    end.sort_by { |entry| entry["date"] }
  end
end
