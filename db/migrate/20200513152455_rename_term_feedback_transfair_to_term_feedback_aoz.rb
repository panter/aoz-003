class RenameTermFeedbackTransfairToTermFeedbackAoz < ActiveRecord::Migration[5.1]
  def change
    rename_column :assignment_logs, :term_feedback_transfair, :term_feedback_aoz
    rename_column :assignments, :term_feedback_transfair, :term_feedback_aoz
    rename_column :group_assignment_logs, :term_feedback_transfair, :term_feedback_aoz
    rename_column :group_assignments, :term_feedback_transfair, :term_feedback_aoz
  end
end
