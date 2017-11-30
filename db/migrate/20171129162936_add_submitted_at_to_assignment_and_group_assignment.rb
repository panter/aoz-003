class AddSubmittedAtToAssignmentAndGroupAssignment < ActiveRecord::Migration[5.1]
  def change
    remove_column :assignments, :confirmation, :boolean
    add_column :assignments, :submitted_at, :datetime
    add_column :group_assignments, :submitted_at, :datetime
  end
end
