class AddStateToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :state, :string
  end
end
