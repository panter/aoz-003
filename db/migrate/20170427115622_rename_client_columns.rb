class RenameClientColumns < ActiveRecord::Migration[5.1]
  def change
    rename_column :clients, :c_authority, :competent_authority
    rename_column :clients, :i_authority, :involved_authority
    rename_column :clients, :firstname, :first_name
    rename_column :clients, :lastname, :last_name
    rename_column :clients, :dob, :date_of_birth
  end
end
