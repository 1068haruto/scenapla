class AddLifespanToAssetLifespans < ActiveRecord::Migration[7.2]
  def change
    add_column :asset_lifespans, :lifespan_years, :integer
    add_column :asset_lifespans, :lifespan_months, :integer
  end
end
