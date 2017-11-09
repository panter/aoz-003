module GroupAssignmentAndAssignmentScopes
  extend ActiveSupport::Concern

  included do
    scope :created_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }

    scope :no_end, (-> { where(period_end: nil) })
    scope :has_end, (-> { where.not(period_end: nil) })
    scope :end_before, ->(date) { where('period_end < ?', date) }
    scope :end_after, ->(date) { where('period_end > ?', date) }
    scope :end_within, ->(date_range) { where(period_end: date_range) }
    scope :end_in_future, (-> { where('period_end > ?', Time.zone.today) })
    scope :not_ended, (-> { no_end.or(end_in_future) })

    scope :no_start, (-> { where(period_start: nil) })
    scope :started, (-> { where('period_start < ?', Time.zone.today) })
    scope :will_start, (-> { where('period_start > ?', Time.zone.today) })
    scope :start_before, ->(date) { where('period_start < ?', date) }
    scope :start_after, ->(date) { where('period_start > ?', date) }
    scope :start_within, ->(date_range) { where(period_start: date_range) }
    scope :started_six_months_ago, (-> { where('period_start < ?', 6.months.ago.to_date) })
    scope :started_six_weeks_ago, (-> { where('period_start < ?', 6.weeks.ago.to_date) })

    scope :active, (-> { not_ended.started })
    scope :inactive, (-> { ended.or(no_start) })

    scope :with_hours, (-> { joins(:hours) })

    scope :active_between, lambda { |start_date, end_date|
      no_end.start_before(end_date)
            .or(
              start_before(end_date).end_after(start_date)
            )
    }
  end
end
