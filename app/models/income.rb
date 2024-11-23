class Income < ApplicationRecord
  belongs_to :user
  belongs_to :simulation 

  enum person_type: { 本人: "本人", 配偶者: "配偶者" }

  validates :person_type, presence: true
  validates :income, numericality: { greater_than_or_equal_to: 0 }
  validates :retirement_date, presence: true
  validates :retirement_pay, numericality: { greater_than_or_equal_to: 0 }
end
