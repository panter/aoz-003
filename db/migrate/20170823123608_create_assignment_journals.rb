class CreateAssignmentJournals < ActiveRecord::Migration[5.1]
  def change
    create_table :assignment_journals do |t|
      t.text :goals
      t.text :achievements
      t.text :future
      t.text :comments
      t.boolean :conversation
      t.datetime :deleted_at, index: true
      t.belongs_to :volunteer
      t.belongs_to :assignment
      t.references :author, index: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
