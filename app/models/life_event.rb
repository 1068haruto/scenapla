class LifeEvent < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum event_type: { 現実: 0, 理想: 1 }

  validates :user_id, presence: true
  validates :simulation_id, presence: true
  validates :event_type, presence: true
  validates :event_date, presence: true
  validates :title, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_span, presence: true

  def self.update_simulation_data(simulation_id)
    # 指定されたsimulation_idに関連するlife_eventsを取得
    life_events = LifeEvent.where(simulation_id: simulation_id)
  
    # 年ごとのamountを格納するための配列
    year_amounts = []
  
    life_events.each do |event|
      # payment_span分だけループして、年を加算しながらamountを追加
      (0...event.payment_span).each do |i|
        year = event.event_date.year + i
        year_amounts << { date: year, amount: -event.amount } # ここでamountをマイナスにして追加
      end
    end
  
    # 年ごとにamountを集計（重複する年があれば合計する）
    aggregated_year_amounts = year_amounts.group_by { |event| event[:date] }.transform_values do |events|
      events.sum { |event| event[:amount] } # 合計してamountを算出
    end
  
    # ハッシュ配列に変換（ここでamountをマイナスにしている）
    real_life_event_data = aggregated_year_amounts.map do |year, amount|
      { date: year, amount: amount } # ここでamountは既にマイナスになっている
    end
  
    # simulationテーブルを直接更新
    Simulation.find(simulation_id).update(real_life_event_data: real_life_event_data)
  end
end
