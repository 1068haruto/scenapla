class CreateSimulations < ActiveRecord::Migration[7.2]
  def change
    create_table :simulations do |t|
      t.references :user, foreign_key: true, null: false
      t.jsonb :income_data
      t.jsonb :expense_data
      t.jsonb :user_asset_data
      t.jsonb :real_event_data
      t.jsonb :ideal_event_data
      t.timestamps
    end
  end
end
