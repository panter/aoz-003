class AddTerminationOfAssignmentFields < ActiveRecord::Migration[5.1]
  def change
    change_table :assignments do |t|
      t.references :period_end_set_by, references: :users
      t.datetime :termination_submitted_at
      t.references :termination_submitted_by, references: :users
      t.datetime :termination_verified_at
      t.references :termination_verified_by, references: :users
    end

    change_table :reminder_mailing_volunteers do |t|
      t.datetime :process_submitted_at
      t.references :process_submitted_by, references: :users
    end

    change_table :reminder_mailings do |t|
      t.boolean :obsolete, default: false
    end
  end
end
