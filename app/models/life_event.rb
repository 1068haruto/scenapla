class LifeEvent < ApplicationRecord
  include Constants

  belongs_to :user
  belongs_to :simulation

  enum event_type: ApplicationEnums::EVENT_TYPES

  validates :user_id, :simulation_id, presence: true
  validates :event_type, :event_date, :title, :payment_period, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Gateway
  def self.generate_life_event_data(user)
    DataGenerator::LifeEventDataGenerator.new(user).call
  end

  # Cast to Date
  def event_date=(value)
    super(value.present? ? Date.new(value.to_i, JANUARY, FIRST) : value)
  end
end
