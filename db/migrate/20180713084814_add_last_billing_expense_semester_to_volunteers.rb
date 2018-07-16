class AddLastBillingExpenseSemesterToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :last_billing_expense_on, :datetime
  end
end
