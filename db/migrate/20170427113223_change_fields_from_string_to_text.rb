class ChangeFieldsFromStringToText < ActiveRecord::Migration[5.1]
  def change
    change_column :clients, :goals, :text
    change_column :clients, :education, :text
    change_column :clients, :hobbies, :text
    change_column :clients, :interests, :text
    change_column :clients, :comments, :text
    change_column :clients, :goals, :text
    change_column :clients, :c_authority, :text
    change_column :clients, :i_authority, :text
  end
end
