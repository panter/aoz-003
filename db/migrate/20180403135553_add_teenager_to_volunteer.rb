class AddTeenagerToVolunteer < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :teenager, :boolean
  end
end
