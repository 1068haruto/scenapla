class CreateAssets < ActiveRecord::Migration[7.2]
  def change
    create_table :assets do |t|
      t.bigint :user_id, null: false
      t.bigint :simulation_id, null: false
      t.integer :person_type, null: false, default: 0
      t.integer :asset_type, null: false, default: 0
      t.decimal :amount, null: false, default: 0.0
      t.decimal :yield
      t.timestamps null: false
    end
  end
end
