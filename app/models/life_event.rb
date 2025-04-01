class LifeEvent < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum event_type: { 現実: 0, 理想: 1 }

  validates :user_id, :simulation_id, presence: true
  validates :event_type, :event_date, :title, :payment_period, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # カスタムセッター：入力された年をdate型に変換
  def event_date=(value)
    super(value.present? ? Date.new(value.to_i, 1, 1) : value)
  end

  def self.generate_life_event_data_for(user)
    life_events = where(user: user)
    real_events = life_events.where(event_type: 0)
    ideal_events = life_events.where(event_type: 1)

    real_event_data = aggregate_event_data(real_events)
    ideal_event_data = aggregate_event_data(real_events + ideal_events) if ideal_events.present?

    { real_event_data: real_event_data, ideal_event_data: ideal_event_data }
  end

  private

  def self.aggregate_event_data(events)
    year_amounts = extract_yearly_amounts(events)
    aggregate_by_year(year_amounts)
  end

  def self.extract_yearly_amounts(events)
    events.flat_map do |event|
      (0...event.payment_period).map do |i|
        { date: event.event_date.year + i, amount: -event.amount }
      end
    end
  end

  def self.aggregate_by_year(year_amounts)
    grouped_events_by_date = year_amounts.group_by { |event| event[:date] }

    aggregated_amounts = grouped_events_by_date.transform_values do |events|
      events.sum { |event| event[:amount] }
    end

    aggregated_amounts.map do |year, amount|
      { date: year, amount: amount }
    end
  end
end
