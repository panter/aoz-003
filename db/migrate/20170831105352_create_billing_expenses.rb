class CreateBillingExpenses < ActiveRecord::Migration[5.1]
  def change
    create_table :billing_expenses do |t|
      t.integer :amount
      t.belongs_to :volunteer
      t.belongs_to :assignment
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
