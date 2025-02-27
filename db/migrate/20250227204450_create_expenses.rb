class CreateExpenses < ActiveRecord::Migration[7.2]
  def change
    create_table :expenses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :simulation, null: false, foreign_key: true
      t.decimal "housing_expenses", null: false, default: "0.0"
      t.date "repayment_date"
      t.decimal "living_expenses", null: false, default: "0.0"
      t.decimal "monthly_premiums", null: false, default: "0.0"
      t.decimal "other_expenses", null: false, default: "0.0"
      t.timestamps
      t.check_constraint "housing_expenses >= 0::numeric", name: "check_expenses_housing_expenses_positive"
      t.check_constraint "living_expenses >= 0::numeric", name: "check_expenses_living_expenses_positive"
      t.check_constraint "monthly_premiums >= 0::numeric", name: "check_expenses_monthly_premiums_positive"
      t.check_constraint "other_expenses >= 0::numeric", name: "check_expenses_other_expenses_positive"
    end
  end
end