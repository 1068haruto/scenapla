class ChangeSimulations < ActiveRecord::Migration[7.2]
  def change
    change_column_null :simulations, :inflation_rate, true 
    change_column_default :simulations, :inflation_rate, 1

    change_column_null :simulations, :income_data, true

    add_column :simulations, :expense_data, :jsonb, null: true
    add_column :simulations, :asset_data, :jsonb, null: true
    add_column :simulations, :lifeevent_data, :jsonb, null: true
  end
end
