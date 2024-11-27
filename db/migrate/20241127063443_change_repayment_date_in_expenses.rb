class ChangeRepaymentDateInExpenses < ActiveRecord::Migration[7.2]
  def change
    change_column :expenses, :repayment_date, :date, null: true, default: nil
  end
end
