class ChangeColumnsInScenarios < ActiveRecord::Migration[7.2]
  def change
    change_column_null :scenarios, :scenario_type, true
    change_column_null :scenarios, :asset_scenario, true
    change_column_null :scenarios, :balance_scenario, true
    change_column_null :scenarios, :total_income, true
    change_column_null :scenarios, :total_expense, true
    change_column_null :scenarios, :total_balance, true
    change_column_null :scenarios, :withdrawal, true
    change_column_null :scenarios, :shortage, true
  end
end
