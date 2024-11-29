class Simulation < ApplicationRecord
  belongs_to :user
  has_many :incomes
  has_many :expenses
  has_many :user_assets
  has_many :life_events

  validates :user_id, presence: true
end
