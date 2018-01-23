class MakeGroupAssignmentLogEqualToGroupAssignment < ActiveRecord::Migration[5.1]
  def change
    change_table :group_assignment_logs do |t|
      t.datetime :submitted_at

      t.timestamps
    end
  end
end
