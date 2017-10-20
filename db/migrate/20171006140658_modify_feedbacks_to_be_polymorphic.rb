class ModifyFeedbacksToBePolymorphic < ActiveRecord::Migration[5.1]
  def up
    add_reference :feedbacks, :feedbackable, polymorphic: true, index: true
    Feedback.with_deleted.each do |feedback|
      feedback.update(feedbackable: feedback.assignment)
    end
    remove_belongs_to :feedbacks, :assignment
  end

  def down
    add_reference :feedbacks, :assignments, foreign_key: true
    Feedback.with_deleted.where(feedbackable_type: 'Assignment').each do |feedback|
      feedback.update(assignment_id: feedback.feedbackable_id)
    end
    remove_belongs_to :feedbacks, :feedbackable
  end
end
