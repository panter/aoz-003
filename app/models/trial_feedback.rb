class TrialFeedback < ApplicationRecord
  include NotMarkedDone

  belongs_to :volunteer
  belongs_to :author, class_name: 'User'
  belongs_to :trial_feedbackable, polymorphic: true, optional: true
  belongs_to :reviewer, class_name: 'User', optional: true
  belongs_to :marked_done_by, class_name: 'User', optional: true

  scope :author_volunteer, (-> { joins(:volunteer).where('author_id = volunteers.user_id') })
  scope :need_review, -> { where(reviewer_id: nil) }

  validates :body, presence: true

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
