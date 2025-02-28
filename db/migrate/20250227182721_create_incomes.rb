class CreateIncomes < ActiveRecord::Migration[7.2]
  def change
    create_table :incomes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :simulation, null: false, foreign_key: true
      t.integer :person_type, null: false, default: 0
      t.decimal :amount, null: false, default: 0.0
      t.date :retirement_date, null: false
      t.decimal :retirement_pay, null: false, default: 0.0
      t.timestamps
      t.check_constraint("amount >= 0::numeric", name: "check_incomes_amount_positive")
      t.check_constraint("retirement_pay >= 0::numeric", name: "check_incomes_retirement_pay_positive")
    end
  end
end
