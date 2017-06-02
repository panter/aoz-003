class RemoveColumsFromClient < ActiveRecord::Migration[5.1]
  def change
    remove_column :clients, :first_name, :string
    remove_column :clients, :last_name, :string
    remove_column :clients, :street, :string
    remove_column :clients, :zip, :string
    remove_column :clients, :city, :string
    remove_column :clients, :phone, :string
    remove_column :clients, :email, :string
  end
end
