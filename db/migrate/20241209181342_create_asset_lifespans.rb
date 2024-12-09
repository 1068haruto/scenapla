class CreateAssetLifespans < ActiveRecord::Migration[7.2]
  def change
    create_table :asset_lifespans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :simulation, null: false, foreign_key: true
      t.jsonb :yearly_lifespans, null: false, default: {}

      t.timestamps
    end
  end
end
