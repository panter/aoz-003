class AddBankAccountToVolunteer < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :bank, :string
    add_column :volunteers, :iban, :string
    add_column :volunteers, :waive, :boolean, default: false
  end
end
