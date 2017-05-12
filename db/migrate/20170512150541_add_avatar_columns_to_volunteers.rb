class AddAvatarColumnsToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_attachment :volunteers, :avatar
  end
end
