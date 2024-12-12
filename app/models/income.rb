class Income < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum person_type: { 本人: "本人", 配偶者: "配偶者" }

  validates :person_type, presence: true
  validates :income, numericality: { greater_than_or_equal_to: 0, message: 'は0以上のプラス値で入力して下さい' }
  validates :retirement_date, presence: true
  validates :retirement_pay, numericality: { greater_than_or_equal_to: 0, message: 'は0以上のプラス値で入力して下さい' }

  # 各年の収入を計算するメソッド
  def calculate_yearly_income_data
    income_data = []

    (Date.current.year..retirement_date.year).each do |year|
      yearly_income = income.to_i * 12
      total_amount = (year == retirement_date.year) ? (yearly_income + retirement_pay.to_i) : yearly_income
      income_data << { date: year, amount: total_amount }
    end

    income_data
  end
end
