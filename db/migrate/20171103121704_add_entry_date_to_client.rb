class AddEntryDateToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :entry_date, :string
  end
end
