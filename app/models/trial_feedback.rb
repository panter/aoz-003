class TrialFeedback < ApplicationRecord
  include FeedbackTrialFeedbackCommon

  belongs_to :volunteer
  belongs_to :author, class_name: 'User', inverse_of: 'trial_feedbacks',
    foreign_key: 'author_id'

  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id',
    inverse_of: 'reviewed_trial_feedbacks'
  belongs_to :trial_feedbackable, polymorphic: true, optional: true

  validates :body, presence: true


  def assignment?
    trial_feedbackable_type == 'Assignment'
  end

  def group_offer?
    trial_feedbackable_type == 'GroupOffer'
  end

  def trial_feedbackable_id_and_type=(id_and_type)
    self.trial_feedbackable_id, self.trial_feedbackable_type = id_and_type.split(',', 2)
  end

  def trial_feedbackable_id_and_type
    "#{trial_feedbackable_id},#{trial_feedbackable_type}"
  end
end
