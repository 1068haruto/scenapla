class UserAsset < ApplicationRecord
  include Constants

  belongs_to :user
  belongs_to :simulation

  enum person_type: ApplicationEnums::PERSON_TYPES
  enum asset_type: ApplicationEnums::ASSET_TYPES

  validates :user_id, :simulation_id, presence: true
  validates :person_type, :asset_type, presence: true
  validates :amount, :return_rate,
              presence: true, numericality: { greater_than_or_equal_to: 0 }
end
