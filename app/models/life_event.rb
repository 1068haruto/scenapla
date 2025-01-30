class LifeEvent < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum event_type: { 現実: 0, 理想: 1 }

  validates :user_id, :simulation_id, presence: true
  validates :event_type, :event_date, :title, :payment_span, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.generate_life_event_data_for(user)
    life_events = where(user: user)

    # event_typeごとにフィルタリング
    real_life_events = life_events.where(event_type: 0)  # 現実
    ideal_life_events = life_events.where(event_type: 1)  # 理想（単独で計算）

    real_life_event_data = aggregate_event_data(real_life_events)
    ideal_life_event_data = aggregate_combined_event_data(real_life_events, ideal_life_events) if ideal_life_events.present?

    # シミュレーションデータ更新用に返す
    { real_life_event_data: real_life_event_data, ideal_life_event_data: ideal_life_event_data }
  end

  private

  def self.aggregate_event_data(events)
    year_amounts = extract_yearly_amounts(events)
    aggregate_by_year(year_amounts)
  end

  def self.extract_yearly_amounts(events)
    events.flat_map do |event|
      (0...event.payment_span).map do |i|
        { date: event.event_date.year + i, amount: -event.amount }
      end
    end
  end

  def self.aggregate_by_year(year_amounts)
    year_amounts.group_by { |event| event[:date] }.transform_values do |events|
      events.sum { |event| event[:amount] }
    end.map { |year, amount| { date: year, amount: amount } }
  end

  #-----------------

  def self.aggregate_combined_event_data(real_events, ideal_events)
    real_data = aggregate_event_data(real_events)
    ideal_data = aggregate_event_data(ideal_events)
    merge_yearly_amounts(real_data, ideal_data)
  end

  def self.merge_yearly_amounts(real_data, ideal_data)
    combined_data = (real_data + ideal_data).group_by { |event| event[:date] }
    combined_data.transform_values do |events|
      events.sum { |event| event[:amount] }
    end.map { |year, amount| { date: year, amount: amount } }
  end
end
