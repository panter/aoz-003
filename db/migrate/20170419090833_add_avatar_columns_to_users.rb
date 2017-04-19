class AddAvatarColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :profiles, :picture, :string
    add_attachment :profiles, :avatar
  end
end
