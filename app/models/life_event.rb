class LifeEvent < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum event_type: { 現実: 0, 理想: 1 }
  enum payment_span: { 一括払い: 0, 毎年支払い: 1 }

  validates :user_id, presence: true
  validates :simulation_id, presence: true
  validates :event_type, presence: true
  validates :event_date, presence: true
  validates :title, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_span, presence: true
end
