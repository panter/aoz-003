class AddTimestampsToGroupAssignment < ActiveRecord::Migration[5.1]
  def change
    add_timestamps :group_assignments, null: true
    GroupAssignment.with_deleted.update_all(created_at: Time.zone.now, updated_at: Time.zone.now)
    change_column_null :group_assignments, :created_at, false
    change_column_null :group_assignments, :updated_at, false
  end
end
