class AddTerminationSubmittedAtToAssignment < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :terminated_at, :datetime
  end
end
