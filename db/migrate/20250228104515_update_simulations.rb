class UpdateSimulations < ActiveRecord::Migration[7.2]
  def change
    remove_column :simulations, :inflation_rate, :decimal

    change_column_null :simulations, :income_data, true

    add_column :simulations, :expense_data, :jsonb
    add_column :simulations, :user_asset_data, :jsonb
    add_column :simulations, :real_event_data, :jsonb
    add_column :simulations, :ideal_event_data, :jsonb

    remove_timestamps :simulations, null: false
    add_timestamps :simulations, null: false
  end
end
