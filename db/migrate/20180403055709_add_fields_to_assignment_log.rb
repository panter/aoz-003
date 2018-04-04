class AddFieldsToAssignmentLog < ActiveRecord::Migration[5.1]
  def change
    add_column :assignment_logs, :assignment_description, :string
    add_column :assignment_logs, :first_meeting, :string
    add_column :assignment_logs, :frequency, :string
    add_column :assignment_logs, :trial_period_end, :string
    add_column :assignment_logs, :duration, :string
    add_column :assignment_logs, :special_agreement, :string
    add_column :assignment_logs, :agreement_text, :text
  end
end
