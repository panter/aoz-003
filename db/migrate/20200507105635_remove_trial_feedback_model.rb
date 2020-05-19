class RemoveTrialFeedbackModel < ActiveRecord::Migration[5.1]
  def change
    drop_table :trial_feedbacks
  end
end
