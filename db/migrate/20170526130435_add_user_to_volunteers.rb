class AddUserToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_reference :volunteers, :user, foreign_key: true
  end
end
