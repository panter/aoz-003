class RenameGenderCollection < ActiveRecord::Migration[5.1]
  def change
    rename_column :clients, :gender, :salutation
    rename_column :volunteers, :gender, :salutation
  end
end
