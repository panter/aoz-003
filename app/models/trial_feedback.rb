class TrialFeedback < ApplicationRecord
  include FeedbackAndTrialFeedbackCommons

  belongs_to :reviewer, class_name: 'User', optional: true

  scope :need_review, -> { where(reviewer_id: nil) }

  validates :body, presence: true
end
