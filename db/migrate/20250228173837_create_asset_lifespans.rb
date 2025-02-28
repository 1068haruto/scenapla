class CreateAssetLifespans < ActiveRecord::Migration[7.2]
  def change
    create_table :asset_lifespans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :simulation, null: false, foreign_key: true
      t.integer :lifespan_years, null: false, default: 0
      t.integer :lifespan_months, null: false, default: 0
      t.jsonb :asset_lifespan_scenario, null: false, default: {}
      t.timestamps
      t.check_constraint("lifespan_years >= 0::numeric", name: "check_asset_lifespans_lifespan_years_positive")
      t.check_constraint("lifespan_months >= 0::numeric", name: "check_asset_lifespans_lifespan_months_positive")
    end
  end
end
