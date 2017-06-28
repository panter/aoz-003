class AddColumnsToClients < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :entry_year, :date
    add_column :clients, :gender_request, :string
    add_column :clients, :age_request, :string
    add_column :clients, :other_request, :string

    remove_column :clients, :hobbies, :text
  end
end
