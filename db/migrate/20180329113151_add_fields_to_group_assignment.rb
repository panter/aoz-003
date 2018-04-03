class AddFieldsToGroupAssignment < ActiveRecord::Migration[5.1]
  def change
    add_column :group_assignments, :place, :string
    add_column :group_assignments, :description, :text
    add_column :group_assignments, :happens_at, :string
    add_column :group_assignments, :frequency, :string
    add_column :group_assignments, :trial_period_end, :string
    add_column :group_assignments, :agreement_text, :text
  end
end
