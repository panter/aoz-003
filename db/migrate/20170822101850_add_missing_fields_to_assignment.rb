class AddMissingFieldsToAssignment < ActiveRecord::Migration[5.1]
  def change
    change_table :assignments do |t|
      t.datetime :assignment_start
      t.datetime :assignment_end
      t.datetime :performance_appraisal_review
      t.datetime :probation_period
      t.datetime :home_visit
      t.datetime :first_instruction_lesson
    end
  end
end
