class AddTerminationSubmittedAtToAssignment < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :termination_submitted_at, :datetime
  end
end
