class AddOverwrittenAmountToBillingExpenses < ActiveRecord::Migration[5.1]
  def change
    add_column :billing_expenses, :overwritten_amount, :integer
  end
end
