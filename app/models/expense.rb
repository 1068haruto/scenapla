class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  AGE_LIMIT = 70
  MONTHS_IN_A_YEAR = 12

  validates :user_id, :simulation_id, presence: true
  validates :housing_expenses, :living_expenses, :monthly_premiums, :other_expenses,
             presence: true, numericality: { greater_than_or_equal_to: 0 }

  # カスタムセッター：入力された年をdate型に変換
  def repayment_date=(value)
    super(value.present? ? Date.new(value.to_i, 1, 1) : value)
  end

  def self.generate_expense_data_for(user)
    latest_expense = user.expenses.last

    current_year = Date.today.year
    year_age_seventy = current_year + (AGE_LIMIT - user.calculate_user_age)

    latest_expense.calculate_yearly_expenses(current_year, year_age_seventy)
  end

  def calculate_yearly_expenses(current_year, year_age_seventy)
    (current_year..year_age_seventy).map do |year|
      yearly_expense = calculate_yearly_expense_for_year(year)
      { date: year, amount: yearly_expense }
    end
  end

  # 年次支出額を計算
  def calculate_yearly_expense_for_year(year)
    repayment_year = repayment_date&.year.to_i

    if repayment_year == 0 || year <= repayment_year
      total_monthly_expense * MONTHS_IN_A_YEAR * -1
    else
      reduced_monthly_expense * MONTHS_IN_A_YEAR * -1
    end
  end

  # 総月次支出を計算
  def total_monthly_expense
    housing_expenses + living_expenses + monthly_premiums + other_expenses
  end

  # ローン返済終了後の月次支出を計算
  def reduced_monthly_expense
    living_expenses + monthly_premiums + other_expenses
  end
end
