class Income < ApplicationRecord
  include Constants

  belongs_to :user
  belongs_to :simulation

  enum person_type: ApplicationEnums::PERSON_TYPES

  validates :user_id, :simulation_id, presence: true
  validates :person_type, :retirement_date, presence: true
  validates :monthly_income, :yearly_bonus, :retirement_pay, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # income_dataの作成-> Array
  def self.generate_income_data(user)
    yearlyTotals = Hash.new(0)
    currentYear = Date.current.year

    user.incomes.each do |income|
      retirementYear = income.retirement_date.year
      yearlyAmount = (income.monthly_income * MONTHS_IN_A_YEAR) + income.yearly_bonus

      (currentYear..retirementYear).each do |year|
        totalAmount = yearlyAmount
        if year == retirementYear
          totalAmount += income.retirement_pay
        end
        yearlyTotals[year] += totalAmount
      end
    end

    FormatService.format(yearlyTotals)
  end

  # Dateにキャスト
  def retirement_date=(value)
    super(value.present? ? Date.new(value.to_i, JANUARY, FIRST) : value)
  end
end
