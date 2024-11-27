class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  validates :user_id, presence: true
  validates :simulation_id, presence: true
  
  validates :housing_expense, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :repayment_date, presence: true
  validates :living_expenses, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :monthly_premiums, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :other_expenses, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def update_simulation_expense_data(current_user)
    current_year = Date.today.year
    retirement_date = current_user.incomes.order(created_at: :desc).first.retirement_date
    expense_data = calculate_expenses(current_year, retirement_date)

    simulation_record = current_user.simulation
    if simulation_record
      simulation_record.update(expense_data: expense_data)
    else
      errors.add(:simulation, "関連するシミュレーションが存在しません")
    end
  end

  def calculate_expenses(current_year, retirement_date)
    total_expense_per_month = housing_expense + living_expenses + monthly_premiums + other_expenses
    expense_data = []

    if repayment_date.nil?
      # 住宅ローンがない場合
      (current_year..retirement_date.year).each do |year|
        yearly_expense = total_expense_per_month * 12 * -1
        expense_data << { date: year, amount: yearly_expense }
      end
    else
      # 住宅ローンがある場合
      repayment_year = repayment_date.year.to_i
      (current_year..retirement_date.year).each do |year|
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
