class AddBillingExpensesRefToHours < ActiveRecord::Migration[5.1]
  def change
    add_reference :hours, :billing_expense, foreign_key: true
  end
end
