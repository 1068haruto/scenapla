class Income < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum person_type: { 本人: "本人", 配偶者: "配偶者" }

  validates :person_type, presence: true
  validates :income, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :retirement_date, presence: true
  validates :retirement_pay, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # 入力された年をdate型に整形するカスタムセッター
  def retirement_date=(value)
    super(value.present? ? Date.new(value.to_i, 1, 1) : value)
  end

  # 現在〜退職までの各年の収入計算（ハッシュ配列作成）
  def calculate_income_until_retirement
    income_data = []

    (Date.current.year..retirement_date.year).each do |year|
      income_data << calculate_yearly_income(year)
    end

    income_data
  end

  # 指定されたユーザーの全収入データを1つに整形
  def self.grouped_income_data_for(user)
    all_income_data = user.incomes.flat_map(&:calculate_income_until_retirement)
    grouped_data = all_income_data.group_by { |data| data[:date] }
    format_income_data(grouped_data)
  end

  private

  # 各年毎に収入を合計して整形
  def self.format_income_data(grouped_data)
    grouped_data.map do |year, records|
      {
        date: year,
        amount: records.sum { |record| record[:amount] }
      }
    end
  end

  def calculate_yearly_income(year)
    yearly_amount = income.to_i * 12
    yearly_total_amount = calculate_total_amount(year, yearly_amount)

    { date: year, amount: yearly_total_amount }
  end

  def calculate_total_amount(year, yearly_amount)
    if year == retirement_date.year
      yearly_amount + retirement_pay.to_i
    else
      yearly_amount
    end
  end
end
