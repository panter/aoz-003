module FeedbackTrialFeedbackCommon
  extend ActiveSupport::Concern

  included do
    include ReviewsCommon
    scope :author_volunteer, (-> { joins(:volunteer).where('author_id = volunteers.user_id') })
    scope :since_last_submitted, lambda { |submitted_at|
      if submitted_at
        author_volunteer.submitted_before(submitted_before)
      else
        author_volunteer
      end
    }
  end
end
