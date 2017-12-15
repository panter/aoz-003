class TrialFeedback < ApplicationRecord
  include FeedbackAndTrialFeedbackCommons

  belongs_to :reviewer, class_name: 'User', optional: true
end
