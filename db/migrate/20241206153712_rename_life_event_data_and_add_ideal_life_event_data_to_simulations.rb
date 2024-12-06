class RenameLifeEventDataAndAddIdealLifeEventDataToSimulations < ActiveRecord::Migration[7.2]
  def change
    rename_column :simulations, :life_event_data, :real_life_event_data
    add_column :simulations, :ideal_life_event_data, :jsonb
  end
end
