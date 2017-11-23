class Feedback < ApplicationRecord
  include FeedbackAndTrialFeedbackCommons

  validates :comments, presence: true
end
