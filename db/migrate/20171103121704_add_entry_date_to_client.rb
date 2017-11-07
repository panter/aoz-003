class AddEntryDateToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :entry_date, :string
    Client.find_each do |client|
      client.update(entry_date: client.entry_year)
    end
    remove_column :clients, :entry_year, :date
  end
end
