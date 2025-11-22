class Simulation < ApplicationRecord
  belongs_to :user
  has_many :incomes, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :user_assets, dependent: :destroy
  has_many :life_events, dependent: :destroy
  has_many :scenarios, dependent: :destroy
  has_many :asset_lifespans, dependent: :destroy

  validates :user_id, presence: true
end
