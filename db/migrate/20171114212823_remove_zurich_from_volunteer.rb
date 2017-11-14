class RemoveZurichFromVolunteer < ActiveRecord::Migration[5.1]
  def change
    remove_column :volunteers, :zurich, :boolean
  end
end
