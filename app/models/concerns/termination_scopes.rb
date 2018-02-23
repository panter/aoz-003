module TerminationScopes
  extend ActiveSupport::Concern

  included do
    scope :termination_not_submitted, (-> { field_nil(:termination_submitted_by_id) })
    scope :termination_submitted, (-> { field_not_nil(:termination_submitted_by_id) })

    scope :termination_submitted_before, lambda { |time|
      date_at_or_before(:termination_submitted_at, time)
    }

    scope :termination_submitted_after, lambda { |time|
      date_at_or_after(:termination_submitted_at, time)
    }

    scope :termination_submitted_between, lambda { |start_date, end_date|
      date_between_inclusion(:termination_submitted_at, start_date, end_date)
    }

    scope :unterminated, (-> { field_nil(:termination_verified_by_id) })
    scope :terminated, (-> { field_not_nil(:termination_verified_by_id) })

    scope :termination_verified_before, lambda { |time|
      date_at_or_before(:termination_verified_at, time)
    }

    scope :termination_verified_after, ->(time) { date_at_or_after(:termination_verified_at, time) }

    scope :termination_verified_between, lambda { |start_date, end_date|
      date_between_inclusion(:termination_verified_at, start_date, end_date)
    }

    scope :termination_verified, (-> { field_not_nil(:termination_verified_by) })
  end
end
