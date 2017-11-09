class AddIndexToContactsTablesFullNameField < ActiveRecord::Migration[5.1]
  def change
    add_index :contacts, :full_name
  end
end
