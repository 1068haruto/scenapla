class RemoveAgeGroupFromLifeEvents < ActiveRecord::Migration[7.2]
  def change
    remove_column :life_events, :age_group, :integer
  end
end
