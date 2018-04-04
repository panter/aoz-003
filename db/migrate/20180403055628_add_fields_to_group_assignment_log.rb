class AddFieldsToGroupAssignmentLog < ActiveRecord::Migration[5.1]
  def change
    add_column :group_assignment_logs, :place, :string
    add_column :group_assignment_logs, :description, :text
    add_column :group_assignment_logs, :happens_at, :string
    add_column :group_assignment_logs, :frequency, :string
    add_column :group_assignment_logs, :trial_period_end, :string
    add_column :group_assignment_logs, :agreement_text, :text
  end
end
