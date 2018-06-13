class AddDepartmentToVolunteers < ActiveRecord::Migration[5.1]
  def up
    add_reference :volunteers, :department, foreign_key: true

    Volunteer.all.each do |volunteer|
      department = volunteer.registrar&.department&.last

      if department.present?
        volunteer.department = department
        volunteer.save

        puts "Assigned volunteer to #{department}"
      end
    end
  end

  def down
    remove_reference :volunteers, :department
  end
end
