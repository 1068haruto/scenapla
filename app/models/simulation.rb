class Simulation < ApplicationRecord
  belongs_to :user
  has_many :incomes

  validates :user_id, presence: true
  validates :inflation_rate, presence: true
  validates :income_data, presence: true
end
