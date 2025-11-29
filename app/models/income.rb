class Income < ApplicationRecord
  include Constants

  belongs_to :user
  belongs_to :simulation

  enum person_type: ApplicationEnums::PERSON_TYPES

  validates :user_id, :simulation_id, presence: true
  validates :person_type, :retirement_date, presence: true
  validates :monthly_income, :yearly_bonus, :retirement_pay,
              presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Gateway
  def self.generate_income_data(user)
    DataGenerator::IncomeDataGenerator.new(user).call
  end

  # Cast to Date
  def retirement_date=(value)
    super(value.present? ? Date.new(value.to_i, JANUARY, FIRST) : value)
  end
end
