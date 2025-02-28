class CreateAiAdvices < ActiveRecord::Migration[7.2]
  def change
    create_table :ai_advices do |t|
      t.references :user, null: false, foreign_key: true
      t.text "content", null: false
      t.datetime "real_scenario_updated_at", null: false
      t.timestamps
    end
  end
end