class ChangeDefaultValueAndNullConstraintInUserAssets < ActiveRecord::Migration[7.2]
  def change
    change_column_default :user_assets, :amount, 0
    change_column_null :user_assets, :return_rate, false, 0
    change_column_default :user_assets, :return_rate, 0
  end
end
