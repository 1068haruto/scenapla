class CreateUserAssets < ActiveRecord::Migration[7.2]
  def change
    create_table :user_assets do |t|
      t.bigint :user_id, null: false
      t.bigint :simulation_id, null: false
      t.integer :person_type, null: false, default: 0
      t.integer :asset_type, null: false, default: 0
      t.decimal :amount, null: false, default: 0.0
      t.decimal :return_rate, null: true
      t.timestamps
    end
  end
end
