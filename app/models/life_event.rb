class LifeEvent < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum event_type: { 現実: 0, 理想: 1 }

  validates :user_id, presence: true
  validates :simulation_id, presence: true
  validates :event_type, presence: true
  validates :event_date, presence: true
  validates :title, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0, message: 'は0以上のプラス値で入力して下さい' }
  validates :payment_span, presence: true

  def self.update_simulation_data(simulation_id)
    # 指定されたsimulation_idに関連するlife_eventsを取得
    life_events = LifeEvent.where(simulation_id: simulation_id)
  
    # event_typeごとにフィルタリング
    real_life_events = life_events.where(event_type: 0) # 現実
    ideal_life_events_only = life_events.where(event_type: 1) # 理想（単独で計算）
    
    # 年ごとのamountを格納するための配列
    real_year_amounts = []
    ideal_year_amounts = []
  
    # 現実のlife_eventsを処理
    real_life_events.each do |event|
      (0...event.payment_span).each do |i|
        year = event.event_date.year + i
        real_year_amounts << { date: year, amount: -event.amount }
      end
    end
  
    # 理想のlife_eventsを処理（event_typeが1のみ）
    ideal_life_events_only.each do |event|
      (0...event.payment_span).each do |i|
        year = event.event_date.year + i
        ideal_year_amounts << { date: year, amount: -event.amount }
      end
    end
  
    # 年ごとにamountを集計
    aggregated_real_year_amounts = real_year_amounts.group_by { |event| event[:date] }.transform_values do |events|
      events.sum { |event| event[:amount] }
    end
  
    aggregated_ideal_year_amounts = ideal_year_amounts.group_by { |event| event[:date] }.transform_values do |events|
      events.sum { |event| event[:amount] }
    end
  
    # データ構築
    real_life_event_data = aggregated_real_year_amounts.map do |year, amount|
      { date: year, amount: amount }
    end
  
    # event_typeが0と1の両方を使った計算結果をideal_life_event_dataに統合
    combined_year_amounts = aggregated_real_year_amounts.merge(aggregated_ideal_year_amounts) do |_, real_amount, ideal_amount|
      real_amount + ideal_amount
    end
  
    ideal_life_event_data = combined_year_amounts.map do |year, amount|
      { date: year, amount: amount }
    end
  
    # simulationテーブルを更新
    simulation = Simulation.find(simulation_id)
  
    if real_life_events.exists? && ideal_life_events_only.exists?
      # 0と1のlife_eventが両方存在する場合
      simulation.update(real_life_event_data: real_life_event_data, ideal_life_event_data: ideal_life_event_data)
    elsif real_life_events.exists?
      # 0のみ存在する場合
      simulation.update(real_life_event_data: real_life_event_data, ideal_life_event_data: nil)
    elsif ideal_life_events_only.exists?
      # 1のみ存在する場合
      simulation.update(real_life_event_data: nil, ideal_life_event_data: ideal_life_event_data)
    else
      # どちらも存在しない場合
      simulation.update(real_life_event_data: nil, ideal_life_event_data: nil)
    end
  end
end
