class Income < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  MONTHS_IN_A_YEAR = 12

  enum person_type: { 本人: "本人", 配偶者: "配偶者" }

  validates :user_id, :simulation_id, presence: true
  validates :person_type, presence: true
  validates :income, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :retirement_date, presence: true
  validates :retirement_pay, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # カスタムセッター：入力された年をdate型に変換
  def retirement_date=(value)
    super(value.present? ? Date.new(value.to_i, 1, 1) : value)
  end

  def self.generate_income_data_for(user)
    all_income_data = user.incomes.flat_map(&:calculate_income_until_retirement)
    grouped_data = all_income_data.group_by { |data| data[:date] }
    format_grouped_data(grouped_data)
  end

  # 現在〜退職時の各年の収入計算
  def calculate_income_until_retirement
    income_data = []

    (Date.current.year..retirement_date.year).each do |year|
      income_data << calculate_income_for_year(year)
    end

    income_data
  end

  # 各年毎に収入を合計して整形
  def self.format_grouped_data(grouped_data)
    grouped_data.map do |year, records|
      {
        date: year,
        amount: records.sum { |record| record[:amount] }
      }
    end
  end

  private

  def calculate_income_for_year(year)
    yearly_amount = income.to_i * MONTHS_IN_A_YEAR
    yearly_total_amount = calculate_adjusted_income_for_year(year, yearly_amount)

    { date: year, amount: yearly_total_amount }
  end

  def calculate_adjusted_income_for_year(year, yearly_amount)
    if year == retirement_date.year
      yearly_amount + retirement_pay.to_i
    else
      yearly_amount
    end
  end
end
