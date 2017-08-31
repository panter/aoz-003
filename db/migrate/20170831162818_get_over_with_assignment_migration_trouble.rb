class GetOverWithAssignmentMigrationTrouble < ActiveRecord::Migration[5.1]
  def change
    change_column :assignments, :assignment_start, :date
    change_column :assignments, :assignment_end, :date
  end
end
