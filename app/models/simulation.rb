class Simulation < ApplicationRecord
  belongs_to :user
  has_many :incomes

  validates :user_id, presence: true
end
