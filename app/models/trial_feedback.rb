class TrialFeedback < ApplicationRecord
  attr_reader :trial_feedbackable_id_and_type

  belongs_to :volunteer
  belongs_to :author, class_name: 'User'
  belongs_to :trial_feedbackable, polymorphic: true, optional: true
  belongs_to :reviewer, class_name: 'User', optional: true

  scope :need_review, -> { where(reviewer_id: nil) }

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
