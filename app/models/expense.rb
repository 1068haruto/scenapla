class Expense < ApplicationRecord
  include Constants

  belongs_to :user
  belongs_to :simulation

  validates :user_id, :simulation_id, presence: true
  validates :housing_expenses, :living_expenses, :monthly_premiums, :other_expenses,
              presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Cast to Date
  def repayment_date=(value)
    super(value.present? ? Date.new(value.to_i, JANUARY, FIRST) : value)
  end
end
