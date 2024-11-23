class CreateIncomes < ActiveRecord::Migration[7.2]
  def change
    create_table :incomes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :simulation, null: false, foreign_key: true
      t.string :person_type, null: false
      t.decimal :income, null: false, default: 0
      t.date :retirement_date, null: false
      t.decimal :retirement_pay, default: 0
      t.timestamps

      t.check_constraint "income >= 0", name: "income_positive_check"
      t.check_constraint "retirement_pay >= 0", name: "retirement_pay_positive_check"
    end
  end
end
