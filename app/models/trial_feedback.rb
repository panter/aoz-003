class TrialFeedback < ApplicationRecord
  include FeedbackTrialFeedbackCommon

  belongs_to :volunteer
  belongs_to :author, class_name: 'User', inverse_of: 'trial_feedbacks',
    foreign_key: 'author_id'

  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id',
    inverse_of: 'reviewed_trial_feedbacks', optional: true
  belongs_to :trial_feedbackable, polymorphic: true, optional: true

  validates :body, presence: true

  scope :assignment, (-> { where(trial_feedbackable_type: 'Assignment') })
  scope :group_offer, (-> { where(trial_feedbackable_type: 'GroupOffer') })
  scope :from_assignments, lambda { |assignment_ids|
    assignment.where(trial_feedbackable_id: assignment_ids)
  }
  scope :from_group_offers, lambda { |group_offer_ids|
    group_offer.where(trial_feedbackable_id: group_offer_ids)
  }

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
