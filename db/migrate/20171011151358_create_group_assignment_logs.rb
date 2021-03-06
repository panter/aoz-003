class CreateGroupAssignmentLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :group_assignment_logs do |t|
      t.belongs_to :group_offer, index: true
      t.belongs_to :volunteer, index: true
      t.belongs_to :group_assignment, index: true
      t.string :title, index: true
      t.date :period_start
      t.date :period_end
      t.boolean :responsible, default: false
      t.datetime :deleted_at, index: true
    end
  end
end
