class TrialFeedback < ApplicationRecord
  include FeedbackTrialFeedbackCommon

  belongs_to :volunteer
  belongs_to :author, class_name: 'User'
  belongs_to :trial_feedbackable, polymorphic: true, optional: true

  validates :body, presence: true

  scope :submitted_before, lambda { |submitted_at|
    where('trial_feedbacks.created_at > ?', submitted_at)
  }

  def assignment?
    trial_feedbackable_type == 'Assignment'
  end

  def group_offer?
    trial_feedbackable_type == 'GroupOffer'
  end

  def trial_feedbackable_link_target
    return trial_feedbackable if assignment?
    trial_feedbackable.group_offer
  end

  def trial_feedbackable_id_and_type=(id_and_type)
    self.trial_feedbackable_id, self.trial_feedbackable_type = id_and_type.split(',', 2)
  end

  def trial_feedbackable_id_and_type
    "#{trial_feedbackable_id},#{trial_feedbackable_type}"
  end
end
