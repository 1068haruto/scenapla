class Simulation < ApplicationRecord
  belongs_to :user
  has_many :incomes
  has_many :expenses
  has_many :user_assets

  validates :user_id, presence: true
end
