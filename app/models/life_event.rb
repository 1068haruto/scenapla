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

  # ビジネスロジック：real_life_event_dataを更新
  def self.update_simulation_data(simulation_id)
    # 指定されたsimulation_idに関連するlife_eventsを取得
    life_events = LifeEvent.where(simulation_id: simulation_id)

    # 年ごとにamountを集計（event_dateの年を抽出）
    year_amounts = life_events.group_by { |event| event.event_date.year }.transform_values do |events|
      events.sum { |event| -event.amount } # マイナス値で格納
    end

    # ハッシュ配列に変換
    real_life_event_data = year_amounts.map do |year, amount|
      { date: year, amount: amount } # dateを年のみの形式にする
    end

    # simulationテーブルを直接更新
    Simulation.find(simulation_id).update(real_life_event_data: real_life_event_data)
  end
end
