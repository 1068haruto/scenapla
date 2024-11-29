class CreateLifeEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :life_events do |t|
      t.bigint :user_id, null: false
      t.bigint :simulation_id, null: false
      t.integer :event_type, null: false, default: 0
      t.date :event_date, null: false
      t.integer :age_group
      t.string :title, null: false
      t.decimal :amount, null: false, default: 0
      t.integer :payment_span, null: false, default: 0
      t.timestamps null: false
    end
  end
end
