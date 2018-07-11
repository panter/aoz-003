class AddSubmittedByToAssignments < ActiveRecord::Migration[5.1]
  def change
    change_table :assignments do |t|
      t.references :submitted_by, references: :users
    end

    change_table :assignment_logs do |t|
      t.references :submitted_by, references: :users
    end

    change_table :group_assignments do |t|
      t.references :submitted_by, references: :users
    end

    change_table :group_assignment_logs do |t|
      t.references :submitted_by, references: :users
    end
  end
end
