class CreateBillingExpenses < ActiveRecord::Migration[5.1]
  def change
    create_table :billing_expenses do |t|
      t.integer :amount
      t.string :bank
      t.string :iban
      t.belongs_to :volunteer
      t.belongs_to :assignment
      t.belongs_to :user
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
