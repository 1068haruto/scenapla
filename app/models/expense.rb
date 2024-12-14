class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  validates :user_id, presence: true
  validates :simulation_id, presence: true
  validates :housing_expense, :living_expenses, :monthly_premiums, :other_expenses,
            presence: true, 
            numericality: { greater_than_or_equal_to: 0, message: 'は0以上のプラス値で入力して下さい' }
  validates :repayment_date, allow_nil: true, presence: true

  # 入力された年をdate型に整形するカスタムセッター
  def repayment_date=(value)
    super(value.present? ? Date.new(value.to_i, 1, 1) : value)
  end

  def update_simulation_data(current_user)
    if current_user.age >= 70
      errors.add(:base, "既に70歳以上のため計算を実行できません")
      return
    end
  
    current_year = Date.today.year
    seventy_year_old_year = current_year + (70 - current_user.age)
    expense_data = calculate_expenses(current_year, seventy_year_old_year)
    simulation_record = current_user.simulation
  
    if simulation_record
      simulation_record.update(expense_data: expense_data)
    else
      errors.add(:simulation, "関連するシミュレーションが存在しません")
    end
  end

  def calculate_expenses(current_year, seventy_year_old_year)
    total_expense_per_month = housing_expense + living_expenses + monthly_premiums + other_expenses
    expense_data = []
  
    if repayment_date.nil?
      # 住宅ローンがない場合
      (current_year..seventy_year_old_year).each do |year|
        yearly_expense = total_expense_per_month * 12 * -1
        expense_data << { date: year, amount: yearly_expense }
      end
    else
      # 住宅ローンがある場合
      repayment_year = repayment_date.year.to_i
      (current_year..seventy_year_old_year).each do |year|
        if year <= repayment_year
          yearly_expense = (housing_expense + living_expenses + monthly_premiums + other_expenses) * 12 * -1
        else
          yearly_expense = (living_expenses + monthly_premiums + other_expenses) * 12 * -1
        end
        expense_data << { date: year, amount: yearly_expense }
      end
    end
    expense_data
  end
end
