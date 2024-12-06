class ChangeDefaultPaymentSpanInLifeEvents < ActiveRecord::Migration[7.2]
  def change
    change_column_default :life_events, :payment_span, from: 0, to: 1
  end
end
