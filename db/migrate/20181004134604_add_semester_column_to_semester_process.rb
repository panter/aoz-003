class AddSemesterColumnToSemesterProcess < ActiveRecord::Migration[5.1]
  def change
    change_table :semester_processes do |t|
      t.remove :period_start
      t.remove :period_end
      t.daterange :semester
      t.string :mail_subject_template
      t.text :mail_body_template
      t.datetime :mail_posted_at
      t.references :mail_posted_by, references: :users, index: true
      t.string :reminder_mail_subject_template
      t.text :reminder_mail_body_template
      t.datetime :reminder_mail_posted_at
      t.references :reminder_mail_posted_by, references: :users, index: true
    end
  end
end
