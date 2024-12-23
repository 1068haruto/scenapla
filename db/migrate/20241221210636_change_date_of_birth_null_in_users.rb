class ChangeDateOfBirthNullInUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :date_of_birth, true
  end
end
