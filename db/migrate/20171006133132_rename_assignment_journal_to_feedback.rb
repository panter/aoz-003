class RenameAssignmentJournalToFeedback < ActiveRecord::Migration[5.1]
  def up
    rename_table :assignment_journals, :feedbacks
  end

  def down
    rename_table :feedbacks, :assignment_journals
  end
end
