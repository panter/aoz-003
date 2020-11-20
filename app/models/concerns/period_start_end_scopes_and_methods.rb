module PeriodStartEndScopesAndMethods
  extend ActiveSupport::Concern

  included do
    scope :no_end, (-> { field_nil(:period_end) })
    scope :has_end, (-> { field_not_nil(:period_end) })
    scope :end_before, ->(date) { date_before(:period_end, date) }
    scope :end_at_or_before, ->(date) { date_at_or_before(:period_end, date) }
    scope :end_after, ->(date) { date_after(:period_end, date) }
    scope :end_at_or_after, ->(date) { date_at_or_after(:period_end, date) }

    scope :end_within, lambda { |start_date, end_date|
      date_between_inclusion(:period_end, start_date, end_date)
    }

    scope :ended, (-> { date_at_or_before(:period_end, Time.zone.today) })
    scope :end_in_future, (-> { date_after(:period_end, Time.zone.today) })
    scope :not_ended, (-> { no_end.or(end_in_future) })

    scope :have_start, (-> { field_not_nil(:period_start) })
    scope :no_start, (-> { field_nil(:period_start) })
    scope :started, (-> { date_at_or_before(:period_start, Time.zone.today) })
    scope :will_start, (-> { date_after(:period_start, Time.zone.today) })
    scope :start_before, ->(date) { date_before(:period_start, date) }
    scope :start_at_or_before, ->(date) { date_at_or_before(:period_start, date) }
    scope :start_after, ->(date) { date_after(:period_start, date) }
    scope :start_at_or_after, ->(date) { date_at_or_after(:period_start, date) }

    scope :start_within, lambda { |start_date, end_date|
      date_between_inclusion(:period_start, start_date, end_date)
    }

    scope :started_ca_six_weeks_ago, (-> { start_within(6.weeks.ago.to_date, 8.weeks.ago.to_date) })
    scope :no_start_and_end, (-> { no_start.no_end })

    scope :active, (-> { not_ended.started.or(no_start.end_in_future) })
    scope :active_or_not_yet_active, (-> { active.or(no_start.no_end) })
    scope :stay_active, (-> { active.no_end })
    scope :inactive, (-> { ended.or(no_start_and_end).or(will_start) })

    scope :active_between, lambda { |start_date, end_date|
      no_end.start_before(end_date)
        .or(start_before(end_date).end_after(start_date))
    }

    def started_ca_six_weeks_ago?
      period_start < 6.weeks.ago && period_start > 8.weeks.ago
    end

    def running?
      period_start.present? && period_end.blank?
    end

    def started?
      period_start.present? && period_start <= Time.zone.today
    end

    def ending?
      period_start.present? && period_end.present?
    end

    def ended?
      ending? && period_end <= Time.zone.today
    end

    def no_period?
      period_start.blank? && period_end.blank?
    end
  end
end
