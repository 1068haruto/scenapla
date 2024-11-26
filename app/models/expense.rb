class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  validates :user_id, presence: true
  validates :simulation_id, presence: true
  validates :repayment_date, presence: true
  validates :housing_expense, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :living_expenses, presence: true,  numericality: { greater_than_or_equal_to: 0 }
  validates :monthly_premiums, presence: true,  numericality: { greater_than_or_equal_to: 0 }
  validates :other_expenses, presence: true,  numericality: { greater_than_or_equal_to: 0 }
end
