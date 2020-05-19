class AddGroupAssignmentSpecificActivnessMightEndFieldToVolunteer < ActiveRecord::Migration[5.1]
  def change
    change_table :volunteers do |t|
      t.date :activeness_might_end_assignments
      t.date :activeness_might_end_groups
      t.boolean :active_on_assignment, default: false
      t.boolean :active_on_group, default: false
    end
    Volunteer.reset_column_information
    Volunteer.find_each do |volunteer|
      volunteer.verify_and_update_state
    end
  end
end
