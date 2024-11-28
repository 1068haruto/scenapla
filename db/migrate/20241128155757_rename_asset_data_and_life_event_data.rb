class RenameAssetDataAndLifeEventData < ActiveRecord::Migration[7.2]
  def change
    rename_column :simulations, :asset_data, :user_asset_data
    rename_column :simulations, :lifeevent_data, :life_event_data
  end
end
