class CreateUserAssets < ActiveRecord::Migration[7.2]
  def change
    create_table :user_assets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :simulation, null: false, foreign_key: true
      t.integer :person_type, null: false, default: 0
      t.integer :asset_type, null: false, default: 0
      t.decimal :amount, null: false, default: 0.0
      t.decimal :return_rate, null: false, default: 0.0
      t.timestamps
      t.check_constraint("amount >= 0::numeric", name: "check_user_assets_amount_positive")
      t.check_constraint("return_rate >= 0::numeric", name: "check_user_assets_return_rate_positive")
    end
  end
end
