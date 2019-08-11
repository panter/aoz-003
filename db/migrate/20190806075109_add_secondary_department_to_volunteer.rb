class AddSecondaryDepartmentToVolunteer < ActiveRecord::Migration[5.1]
  def change
  	add_column :volunteers, :secondary_department_id, :bigint, index: true
  end
end
