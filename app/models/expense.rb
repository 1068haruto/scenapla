class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  MONTHS_IN_A_YEAR = 12
  NO_REPAYMENT_YEAR = 0
  JANUARY = 1
  FIRST = 1

  validates :user_id, :simulation_id, presence: true
  validates :housing_expenses, :living_expenses, :monthly_premiums, :other_expenses,
             presence: true, numericality: { greater_than_or_equal_to: 0 }

  # main: expense_dataの作成-> Array
  def self.generate_expense_data(user)
    latest_expense = user.expenses.last
    latest_expense.calculate_until_limit(user)
  end

  # 70歳までの各年の支出を計算-> Array
  def calculate_until_limit(user)
    currentYear = Date.today.year
    yearAtSeventy = user.get_year_at_seventy

    (currentYear..yearAtSeventy).map do |year|
      repaymentYear = repayment_date&.year.to_i  # nil の to_i は 0
      # ローン有無判断
      if repaymentYear == NO_REPAYMENT_YEAR || year <= repaymentYear
        monthly = (housing_expenses + living_expenses + monthly_premiums + other_expenses)
      else
        monthly = (living_expenses + monthly_premiums + other_expenses)
      end
      yearlyExpense = -(monthly * MONTHS_IN_A_YEAR)
      { date: year, amount: yearlyExpense }
    end
  end

  # 返済時期をDateにキャスト
  def repayment_date=(value)
    super(value.present? ? Date.new(value.to_i, JANUARY, FIRST) : value)
  end
end
