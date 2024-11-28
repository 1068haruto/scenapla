class Asset < ApplicationRecord
  validates :user_id, presence: true
  validates :simulation_id, presence: true
  validates :person_type, presence: true
  validates :asset_type, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :yield, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }

  enum person_type: {本人: 0, 配偶者: 1}
  enum asset_type: {預金: 0, 貯蓄型保険: 1, 投資_NISA: 2, 投資_iDeCo: 3, 投資_その他: 4}
end
