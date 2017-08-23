class CreateAssignmentJournals < ActiveRecord::Migration[5.1]
  def change
    create_table :assignment_journals do |t|
      t.text :goals
      t.text :achievements
      t.text :future
      t.text :comments
      t.boolean :conversation
      t.datetime :deleted_at
      t.belongs_to :volunteer
      t.belongs_to :assignment

      t.timestamps
    end

    add_index :assignment_journals, :deleted_at
  end
end
