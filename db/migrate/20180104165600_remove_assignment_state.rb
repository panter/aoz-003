class RemoveAssignmentState < ActiveRecord::Migration[5.1]
  def change
    remove_column :assignments, :state, :string
  end
end
