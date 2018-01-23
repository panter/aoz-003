class MakeGroupAssignmentLogEqualToGroupAssignment < ActiveRecord::Migration[5.1]
  def change
    change_table :group_assignment_logs do |t|
      t.datetime :submitted_at

      t.timestamps
    end
  end

  def up
    GroupAssignmentLog.where(created_at: nil).map do |gal|
      gal.update(created_at: Time.zone.now)
    end
  end
end
