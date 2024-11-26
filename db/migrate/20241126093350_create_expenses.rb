class CreateExpenses < ActiveRecord::Migration[7.2]
  def change
    create_table :expenses do |t|
      t.bigint :user_id, null: false
      t.bigint :simulation_id, null: false
      t.decimal :housing_expense, null: false, default: "0.0"
      t.date :repayment_date, null: false, default: -> { 'CURRENT_DATE' }
      t.decimal :living_expenses, null: false, default: "0.0"
      t.decimal :monthly_premiums, null: false, default: "0.0"
      t.decimal :other_expenses, null: false, default: "0.0"
      t.timestamps null: false

      t.check_constraint('housing_expense >= 0', name: 'check_housing_expense_positive')
      t.check_constraint('living_expenses >= 0', name: 'check_living_expenses_positive')
      t.check_constraint('monthly_premiums >= 0', name: 'check_monthly_premiums_positive')
      t.check_constraint('other_expenses >= 0', name: 'check_other_expenses_positive')
    end
  end
end
