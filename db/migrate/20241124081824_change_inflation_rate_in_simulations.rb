class ChangeInflationRateInSimulations < ActiveRecord::Migration[7.2]
  def change
    change_column :simulations, :inflation_rate, :decimal, null: true, default: nil
  end
end
