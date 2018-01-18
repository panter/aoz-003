class CreateAssignmentLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :assignment_logs do |t|
      t.belongs_to :assignment, foreign_key: true, index: true
      t.belongs_to :volunteer, foreign_key: true, index: true
      t.belongs_to :client, foreign_key: true, index: true
      t.belongs_to :creator, foreign_key: true, references: :users, index: true
      t.belongs_to :period_end_set_by, references: :users, index: true
      t.belongs_to :termination_submitted_by, references: :users, index: true
      t.belongs_to :termination_verified_by, references: :users, index: true

      t.date :period_start
      t.date :period_end
      t.datetime :performance_appraisal_review
      t.datetime :probation_period
      t.datetime :home_visit
      t.datetime :first_instruction_lesson
      t.datetime :progress_meeting
      t.string :short_description
      t.text :goals
      t.text :starting_topic
      t.text :description
      t.string :kind, default: 'accompaniment'
      t.datetime :submitted_at
      t.datetime :termination_submitted_at
      t.datetime :termination_verified_at

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
