class Simulation < ApplicationRecord
  belongs_to :user
  has_many :incomes
  has_many :expenses

  validates :user_id, presence: true
end
