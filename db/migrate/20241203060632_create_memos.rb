class CreateMemos < ActiveRecord::Migration[7.2]
  def change
    create_table :memos do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content
      t.integer :age_group, null: false

      t.timestamps
    end
  end
end
