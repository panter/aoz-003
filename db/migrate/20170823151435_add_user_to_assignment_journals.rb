class AddUserToAssignmentJournals < ActiveRecord::Migration[5.1]
  def change
    add_reference :assignment_journals, :user, foreign_key: true
  end
end
