module DataGenerator
  class IncomeDataGenerator
    # コンストラクタでuser受け取り
    def initialize(user)
      @user = user
    end

    # income_dataの生成-> Array
    def call
      yearly_totals = Hash.new(0)
      current_year = Date.current.year

      @user.incomes.each do |income|
        retirement_year = income.retirement_date.year
        yearly_amount = (income.monthly_income * Constants::MONTHS_IN_A_YEAR) + income.yearly_bonus

        (current_year..retirement_year).each do |year|
          total_amount = yearly_amount
          if year == retirement_year
            total_amount += income.retirement_pay
          end
          yearly_totals[year] += total_amount
        end
      end

      Formatter.format(yearly_totals)
    end
  end
end
