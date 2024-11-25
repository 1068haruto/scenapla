class CreateSimulations < ActiveRecord::Migration[7.2]
  def change
    create_table :simulations do |t|
      t.references :user, foreign_key: true, null: false
      t.decimal :inflation_rate, null: false
      t.jsonb :income_data, null: false 

      t.timestamps
    end
  end
end
