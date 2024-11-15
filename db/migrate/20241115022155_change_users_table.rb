class ChangeUsersTable < ActiveRecord::Migration[7.2]
  def change
    change_column :users, :email, :string, null: false       # default値を削除
    change_column :users, :name, :string, null: false        # null: falseを追加
    change_column :users, :date_of_birth, :date, null: false # null: falseを追加
  end
end
