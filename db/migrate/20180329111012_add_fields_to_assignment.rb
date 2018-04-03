class AddFieldsToAssignment < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :assignment_description, :string
    add_column :assignments, :first_meeting, :string
    add_column :assignments, :frequency, :string
    add_column :assignments, :trial_period_end, :string
    add_column :assignments, :duration, :string
    add_column :assignments, :special_agreement, :string
    add_column :assignments, :agreement_text, :text
  end
end
