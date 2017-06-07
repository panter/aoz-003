class RemoveColumnsFromVolunteer < ActiveRecord::Migration[5.1]
  def change
    remove_column :volunteers, :first_name, :string
    remove_column :volunteers, :last_name, :string
    remove_column :volunteers, :street, :string
    remove_column :volunteers, :zip, :string
    remove_column :volunteers, :city, :string
    remove_column :volunteers, :email, :string
    remove_column :volunteers, :phone, :string
  end
end
