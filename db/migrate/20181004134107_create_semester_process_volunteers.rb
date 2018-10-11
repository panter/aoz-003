class CreateSemesterProcessVolunteers < ActiveRecord::Migration[5.1]
  def change
    create_table :semester_process_volunteers do |t|
      t.references :volunteer, foreign_key: true
      t.references :semester_process, foreign_key: true
      # volunteers "Bestätigen"
      t.datetime :commit_visited_at
      t.datetime :commited_at
      t.references :commited_by, references: :users, index: true
      # superadmins "Uebernehmen"
      t.references :responsible, references: :users, index: true
      t.datetime :responsibility_taken_at
      # superadmins "Quittieren"
      t.references :reviewed_by, references: :users, index: true
      t.datetime :reviewed_at
      # Superadmin takes notes
      t.jsonb :notes

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
