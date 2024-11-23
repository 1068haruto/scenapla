class CreateScenarios < ActiveRecord::Migration[7.2]
  def change
    create_table :scenarios do |t|
      t.references :user, null: false, foreign_key: true
      t.references :simulation, null: false, foreign_key: true
      t.string :scenario_type, null: false
      t.jsonb :asset_scenario, null: false, default: {}
      t.jsonb :balance_scenario, null: false, default: {}
      t.decimal :total_income, null: false
      t.decimal :total_expense, null: false
      t.decimal :total_balance, null: false
      t.decimal :withdrawal, null: false
      t.decimal :shortage, null: false
      t.timestamps
    end
  end
end
