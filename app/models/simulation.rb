class Simulation < ApplicationRecord
  belongs_to :user
  has_many :incomes, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :user_assets, dependent: :destroy
  has_many :life_events, dependent: :destroy
  has_many :scenarios, dependent: :destroy
  has_many :asset_lifespans, dependent: :destroy

  validates :user_id, presence: true

  # ----------simulations_table更新処理----------
  def update_income_data!(user)
    income_data = Income.generate_income_data_for(user)
    update!(income_data: income_data)
  end

  def update_expense_data!(user)
    expense_data = Expense.generate_expense_data_for(user)
    update!(expense_data: expense_data)
  end

  def update_user_asset_data!(user)
    user_asset_data = UserAsset.generate_user_asset_data_for(user)
    update!(user_asset_data: user_asset_data)
  end

  def update_life_event_data!(user)
    life_event_data = LifeEvent.generate_life_event_data_for(user)
    update!(
      real_life_event_data: life_event_data[:real_event_data].presence,
      ideal_life_event_data: life_event_data[:ideal_event_data].presence
    )
  end

  # ----------scenario_data計算処理----------

  # 指定されたシナリオタイプのデータ用意
  def self.calculate_scenario_data(simulation, life_event_data)
    balance_scenario = simulation.merged_income_expense_event(life_event_data)
    total_income = simulation.get_total_income

    datasets = [ simulation.expense_data, life_event_data ]
    datasets << simulation.real_life_event_data if life_event_data != simulation.real_life_event_data
    total_expense = simulation.get_total_expense(*datasets)

    total_balance = total_income + total_expense

    monthly_expense_total = simulation.get_monthly_expense
    withdrawal = (total_balance > 0) ? (total_balance / monthly_expense_total).round(2) : 0
    shortage = (total_balance < 0) ? simulation.calculate_shortage(total_balance) : 0

    calculate_and_save_lifespan_data(simulation)  # 資産寿命の計算と保存

    {
      balance_scenario: balance_scenario,
      total_income: total_income,
      total_expense: total_expense,
      total_balance: total_balance,
      withdrawal: withdrawal,
      shortage: shortage
    }
  end

  # 収入、支出、ライフイベント支出の統合
  def merged_income_expense_event(life_event_data)
    merged = merge_data(income_data, expense_data, life_event_data)

    merged.each_cons(2) do |previous, current|  # 前年の収支を次年に反映
      current["amount"] += previous["amount"]
    end
    merged
  end

  # 生涯収入の計算
  def get_total_income
    income_data.sum { |entry| entry["amount"].to_f }
  end

  # 生涯支出の計算
  def get_total_expense(*datasets)
    merge_data(*datasets).sum { |entry| entry["amount"].to_f }
  end

  # 月間支出の計算(DB側で合計)
  def get_monthly_expense
    expenses.sum(:housing_expense) +
    expenses.sum(:living_expenses) +
    expenses.sum(:monthly_premiums) +
    expenses.sum(:other_expenses)
  end

  # 年間不足額の計算
  def calculate_shortage(total_balance)
    remaining_years = [ 70 - user.calculate_user_age, 0 ].max # 70歳までの残り年数
    return 0 if remaining_years == 0  # 残り年数が0なら不足額は0
    (total_balance.abs / remaining_years.to_f).round(2)  # 年数を浮動小数点数に変換
  end

  # データ統合し、同じdateでamountを合計
  def merge_data(*datasets)
    datasets = datasets.map { |dataset| dataset || [] }  # nilのデータセットは空配列に変換

    merged = datasets.flatten.group_by { |entry| entry["date"] }
    merged.map do |date, entries|
      {
        "date" => date,
        "amount" => entries.sum { |entry| entry["amount"].to_f }
      }
    end.sort_by { |entry| entry["date"] }
  end

  # ----------資産寿命の計算と保存----------

  def self.calculate_and_save_lifespan_data(simulation)
    total_assets = simulation.user_assets.sum(:amount)
    monthly_expense = simulation.get_monthly_expense

    return if monthly_expense <= 0 # 月次支出がない場合、計算をスキップ

    yearly_lifespan = calculate_yearly_lifespan(total_assets, monthly_expense)
    lifespan_years, lifespan_months = convert_to_years_and_months(total_assets, monthly_expense)

    AssetLifespan.update_lifespan_data!(simulation, yearly_lifespan, lifespan_years, lifespan_months)
  end

  def self.calculate_yearly_lifespan(total_assets, monthly_expense)
    yearly_lifespan = {}
    remaining_asset = total_assets
    current_year = Date.today.year
    current_month = Date.today.month

    # 1年目の残り月分を計算
    remaining_months = 12 - current_month + 1 # 現在月を含める
    if remaining_months > 0
      yearly_lifespan[current_year] = remaining_asset
      remaining_asset -= monthly_expense * remaining_months
    end

    # 2年目以降、12ヶ月単位で計算
    next_year = current_year + 1
    annual_expense = monthly_expense * 12
    while remaining_asset > -annual_expense
      yearly_lifespan[next_year] = remaining_asset
      remaining_asset -= annual_expense
      next_year += 1
    end

    yearly_lifespan
  end

  # 資産寿命を年と月に変換
  def self.convert_to_years_and_months(total_assets, monthly_expense)
    total_months = (total_assets / monthly_expense).floor
    [ total_months / 12, total_months % 12 ]
  end
end
