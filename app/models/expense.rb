class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  AGE_LIMIT = 70
  ERROR_MESSAGES = {
    over_age_limit: "既に70歳以上のため計算を実行できません",
    no_simulation: "関連するシミュレーションが存在しません"
  }.freeze

  validates :user_id, :simulation_id, presence: true
  validates :housing_expense, :living_expenses, :monthly_premiums, :other_expenses,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, message: "は0以上のプラス値で入力して下さい" }
  validates :repayment_date, allow_nil: true, presence: true

  # カスタムセッター: 入力された年を date 型に変換
  def repayment_date=(value)
    super(value.present? ? Date.new(value.to_i, 1, 1) : value)
  end

  def update_simulation_data(current_user)
    return unless validate_user_age(current_user)

    expense_data = build_expense_data(current_user)

    simulation_record = current_user.simulation
    if simulation_record
      simulation_record.update(expense_data: expense_data)
    else
      errors.add(:simulation, ERROR_MESSAGES[:no_simulation])
    end
  end

  private

  def validate_user_age(current_user)
    if current_user.calculate_user_age >= AGE_LIMIT
      errors.add(:base, ERROR_MESSAGES[:over_age_limit])
      return false
    end
    true
  end

  def build_expense_data(current_user)
    current_year = Date.today.year
    year_age_seventy = current_year + (AGE_LIMIT - current_user.calculate_user_age)

    calculate_expenses(current_year, year_age_seventy)
  end

  def calculate_expenses(current_year, year_age_seventy)
    total_monthly_expense = housing_expense + living_expenses + monthly_premiums + other_expenses
    repayment_year = repayment_date&.year.to_i
    (current_year..year_age_seventy).map do |year|
      yearly_expense = if repayment_year == 0 || year <= repayment_year
                         total_monthly_expense * 12 * -1
                       else
                         (living_expenses + monthly_premiums + other_expenses) * 12 * -1
                       end
      { date: year, amount: yearly_expense }
    end
  end
end
