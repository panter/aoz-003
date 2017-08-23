class RenameUserToAuthorAssignmentJournals < ActiveRecord::Migration[5.1]
  def change
    rename_column :assignment_journals, :user_id, :author_id
  end
end
