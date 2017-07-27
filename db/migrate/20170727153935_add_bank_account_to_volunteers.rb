class AddBankAccountToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :bank_account, :boolean, default: false
  end
end
