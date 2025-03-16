class CreateIncomes < ActiveRecord::Migration[7.2]
  def change
    create_table :incomes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :simulation, null: false, foreign_key: true
      t.integer :person_type, null: false, default: 0
      t.decimal :monthly_income, null: false, default: 0.0
      t.decimal :yearly_bonus, null: false, default: 0.0
      t.date :retirement_date, null: false
      t.decimal :retirement_pay, null: false, default: 0.0
      t.timestamps
      t.check_constraint("monthly_income >= 0::numeric", name: "check_incomes_monthly_income_positive")
      t.check_constraint("yearly_bonus >= 0::numeric", name: "check_incomes_yearly_bonus_positive")
      t.check_constraint("retirement_pay >= 0::numeric", name: "check_incomes_retirement_pay_positive")
    end
  end
end
