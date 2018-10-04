class CreateSemesterProcessMails < ActiveRecord::Migration[5.1]
  def change
    create_table :semester_process_mails do |t|
      t.references :semester_process_volunteer, foreign_key: true
      t.references :sent_by, references: :users, index: true
      t.datetime :sent_at
      t.string :subject
      t.text :body
      t.integer :type

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
