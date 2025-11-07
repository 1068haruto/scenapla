class Income < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  MONTHS_IN_A_YEAR = 12
  JANUARY = 1
  FIRST = 1

  enum person_type: { 本人: 0, 配偶者: 1 }

  validates :user_id, :simulation_id, presence: true
  validates :person_type, :retirement_date, presence: true
  validates :monthly_income, :yearly_bonus, :retirement_pay, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # main
  def self.generate_income_data_for(user)
    allIncomeData = user.incomes.flat_map(&:calculate_until_retirement)
    groupedData = grouped(allIncomeData)
  end

  # 現在〜退職までの各年の収入計算
  def calculate_until_retirement
    thisYear = Date.current.year
    retirementYear = retirement_date.year
    incomeData = []
    yearlyTotalAmount = (monthly_income.to_i * MONTHS_IN_A_YEAR) + yearly_bonus

    (thisYear..retirementYear).each do |year|
      if year == retirementYear
        yearlyTotalAmount += retirement_pay.to_i
      end
      incomeData << { date: year, amount: yearlyTotalAmount }
    end

    incomeData
  end

  # 同じ年の複数の収入をまとめる
  def self.grouped(allIncomeData)
    groupedByDate = allIncomeData.group_by { |data| data[:date] }
    groupedByDate.map do |year, records|
      {
        date: year,
        amount: records.sum { |record| record[:amount] }
      }
    end
  end

  # Dateにキャスト
  def retirement_date=(value)
    super(value.present? ? Date.new(value.to_i, JANUARY, FIRST) : value)
  end
end
