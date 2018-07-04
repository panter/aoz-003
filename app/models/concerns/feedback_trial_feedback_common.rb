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

    scope :submitted_before, lambda { |submitted_at|
      created_after(submitted_at)
    }

    scope :author_isnt_volunteer, lambda {
      joins(:volunteer).where("#{model_name.plural}.author_id != volunteers.user_id")
    }

    scope :author_is_volunteer, lambda {
      joins(:volunteer).where("#{model_name.plural}.author_id = volunteers.user_id")
    }

    scope :since_last_submitted, lambda { |submitted_at|
      submitted_before(submitted_at) if submitted_at
    }
  end
end
