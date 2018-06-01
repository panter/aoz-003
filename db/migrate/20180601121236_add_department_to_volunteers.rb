class AddDepartmentToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_reference :volunteers, :department, foreign_key: true
  end
end
