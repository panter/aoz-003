class MakeGroupAssignmentLogEqualToGroupAssignment < ActiveRecord::Migration[5.1]
  def change
    change_table :group_assignments do |t|
      t.references :period_end_set_by, references: :users, index: true
      t.references :termination_submitted_by, references: :users, index: true
      t.references :termination_verified_by, references: :users, index: true
      t.datetime :termination_submitted_at
      t.datetime :termination_verified_at
    end

    change_table :group_assignment_logs do |t|
      t.references :period_end_set_by, references: :users, index: true
      t.references :termination_submitted_by, references: :users, index: true
      t.references :termination_verified_by, references: :users, index: true

      t.datetime :termination_submitted_at
      t.datetime :termination_verified_at
      t.datetime :submitted_at
    end

    add_timestamps :group_assignment_logs, null: true
    GroupAssignmentLog.update_all(created_at: Time.zone.now, updated_at: Time.zone.now)
    change_column_null :group_assignment_logs, :created_at, false
    change_column_null :group_assignment_logs, :updated_at, false
  end
end
