class AddTerminationSubmitionAnswersToAssignmentTable < ActiveRecord::Migration[5.1]
  def change
    change_table :assignments do |t|
      t.text :term_feedback_activities
      t.text :term_feedback_success
      t.text :term_feedback_problems
      t.text :term_feedback_transfair
    end

    change_table :assignment_logs do |t|
      t.text :term_feedback_activities
      t.text :term_feedback_success
      t.text :term_feedback_problems
      t.text :term_feedback_transfair
    end
  end
end
