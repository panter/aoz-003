class RenameRelativeColumns < ActiveRecord::Migration[5.1]
  def change
    rename_column :relatives, :firstname, :first_name
    rename_column :relatives, :lastname, :last_name
    rename_column :relatives, :dob, :date_of_birth
  end
end
