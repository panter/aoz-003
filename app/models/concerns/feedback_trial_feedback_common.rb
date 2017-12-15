module FeedbackTrialFeedbackCommon
  extend ActiveSupport::Concern

  included do
    include ReviewsCommon

    scope :author_volunteer, lambda { |toggle|
      return all unless toggle
      if toggle[:author_volunteer] == 'true'
        author_is_volunteer
      elsif toggle[:author_volunteer] == 'false'
        author_isnt_volunteer
      else
        all
      end
    }

    scope :author_isnt_volunteer, (-> { joins(:volunteer).where('author_id != volunteers.user_id') })
    scope :author_is_volunteer, (-> { joins(:volunteer).where('author_id = volunteers.user_id') })

    scope :since_last_submitted, lambda { |submitted_at|
      if submitted_at
        author_volunteer.submitted_before(submitted_at)
      else
        author_volunteer
      end
    }
  end
end
