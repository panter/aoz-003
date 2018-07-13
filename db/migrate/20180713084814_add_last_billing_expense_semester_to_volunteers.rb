class AddLastBillingExpenseSemesterToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :last_billing_expense, :date
  end
end
