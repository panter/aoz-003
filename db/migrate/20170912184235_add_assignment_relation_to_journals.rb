class AddAssignmentRelationToJournals < ActiveRecord::Migration[5.1]
  def change
    change_table :journals do |t|
      t.belongs_to :assignment, foreign_key: true
    end
  end
end
