class Feedback < ApplicationRecord
  include FeedbackTrialFeedbackCommon

  attr_reader :feedbackable_id_and_type

  belongs_to :volunteer
  belongs_to :author, class_name: 'User', inverse_of: 'feedbacks'
  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id',
    inverse_of: 'reviewed_feedbacks'
  belongs_to :feedbackable, polymorphic: true, optional: true

  validates :comments, presence: true

  scope :submitted_before, ->(submitted_at) { where('feedbacks.created_at > ?', submitted_at) }

  def assignment?
    feedbackable_type == 'Assignment'
  end

  def group_offer?
    feedbackable_type == 'GroupOffer'
  end

  def feedbackable_id_and_type=(id_and_type)
    self.feedbackable_id, self.feedbackable_type = id_and_type.split(',', 2)
  end

  def feedbackable_id_and_type
    "#{feedbackable_id},#{feedbackable_type}"
  end
end
