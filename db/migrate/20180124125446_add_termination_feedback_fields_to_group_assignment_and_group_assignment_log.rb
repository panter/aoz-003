class AddTerminationFeedbackFieldsToGroupAssignmentAndGroupAssignmentLog < ActiveRecord::Migration[5.1]
  def change
    change_table :group_assignments do |t|
      t.text :term_feedback_activities
      t.text :term_feedback_success
      t.text :term_feedback_problems
      t.text :term_feedback_transfair
    end

    change_table :group_assignment_logs do |t|
      t.text :term_feedback_activities
      t.text :term_feedback_success
      t.text :term_feedback_problems
      t.text :term_feedback_transfair
    end
  end
end
