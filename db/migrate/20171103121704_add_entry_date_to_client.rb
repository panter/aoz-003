class AddEntryDateToClient < ActiveRecord::Migration[5.1]
  def change
    remove_column :clients, :entry_year, :date
    add_column :clients, :entry_date, :string
  end
end
