class LifeEvent < ApplicationRecord
  include Constants

  belongs_to :user
  belongs_to :simulation

  enum event_type: { 現実: 0, 理想: 1 }

  validates :user_id, :simulation_id, presence: true
  validates :event_type, :event_date, :title, :payment_period, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # life_event_dataの生成-> Array
  def self.generate_life_event_data(user)
    lifeEvents = where(user: user)
    realEvents = lifeEvents.where(event_type: 0)
    idealEvents = lifeEvents.where(event_type: 1)

    realEventData = calculate_yearly_totals(realEvents)
    idealEventData = nil
    if idealEvents.present?
      idealEventData = calculate_yearly_totals(realEvents + idealEvents)
    end
    { real_event_data: realEventData, ideal_event_data: idealEventData }
  end

  def self.calculate_yearly_totals(events)
    yearlyTotals = Hash.new(0)
    events.each do |event|
      (0...event.payment_period).each do |i|
        year = event.event_date.year + i
        yearlyTotals[year] += -event.amount
      end
    end

    FormatService.format(yearlyTotals)
  end

  # Dateにキャスト
  def event_date=(value)
    super(value.present? ? Date.new(value.to_i, JANUARY, FIRST) : value)
  end
end
