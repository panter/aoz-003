class AddSecondaryPhoneToContacts < ActiveRecord::Migration[5.1]
  def change
    add_column :contacts, :secondary_phone, :string
  end
end
