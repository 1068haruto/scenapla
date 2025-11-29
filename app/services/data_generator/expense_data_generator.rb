module DataGenerator
  class ExpenseDataGenerator
    # コンストラクタでuser受け取り
    def initialize(user)
      @user = user
    end

    # expense_dataの作成-> Array
    def call
      expense = @user.expenses.last
      current_year = Date.today.year
      year_at_seventy = @user.get_year_at_seventy
      repayment_year = expense.repayment_date&.year.to_i # nilのto_iは0

      (current_year..year_at_seventy).map do |year|
        # ローン有無判断
        if repayment_year == Constants::NO_REPAYMENT_YEAR || year <= repayment_year
          monthly = (
            expense.housing_expenses +
            expense.living_expenses +
            expense.monthly_premiums +
            expense.other_expenses
          )
        else
          monthly = (
            expense.living_expenses +
            expense.monthly_premiums +
            expense.other_expenses
          )
        end
        yearly_expense = -(monthly * Constants::MONTHS_IN_A_YEAR)
        { date: year, amount: yearly_expense }
      end
    end
  end
end
