class CreateScenarios < ActiveRecord::Migration[7.2]
  def change
    create_table :scenarios do |t|
      t.references :user, null: false, foreign_key: true
      t.references :simulation, null: false, foreign_key: true
      t.integer :scenario_type
      t.decimal :total_income
      t.decimal :total_expense
      t.decimal :total_balance
      t.decimal :withdrawal
      t.decimal :shortage
      t.jsonb :asset_scenario, default: {}
      t.jsonb :balance_scenario, default: {}
      t.timestamps
    end
  end
end
