class AddRealScenarioUpdatedAtToAiAdvices < ActiveRecord::Migration[7.2]
  def change
    add_column :ai_advices, :real_scenario_updated_at, :datetime
  end
end
