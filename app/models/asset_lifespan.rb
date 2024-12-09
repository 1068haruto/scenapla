class AssetLifespan < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  validates :yearly_lifespans, presence: true
  validates :summary, presence: true
end
