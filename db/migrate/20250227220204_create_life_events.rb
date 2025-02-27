class CreateLifeEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :life_events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :simulation, null: false, foreign_key: true
      t.integer "event_type", null: false, default: 0
      t.date "event_date", null: false
      t.string "title", null: false
      t.decimal "amount", null: false, default: "0.0"
      t.integer "payment_period", null: false, default: 1
      t.timestamps
      t.check_constraint("amount >= 0::numeric", name: "check_life_events_amount_positive")
    end
  end
end