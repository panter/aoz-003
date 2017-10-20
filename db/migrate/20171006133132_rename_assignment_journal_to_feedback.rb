class RenameAssignmentJournalToFeedback < ActiveRecord::Migration[5.1]
  def change
    rename_table :assignment_journals, :feedbacks
  end
end
