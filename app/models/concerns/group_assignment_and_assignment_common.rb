module GroupAssignmentAndAssignmentCommon
  extend ActiveSupport::Concern

  included do
    belongs_to :volunteer
    accepts_nested_attributes_for :volunteer

    has_many :reminder_mailing_volunteers, as: :reminder_mailable, dependent: :destroy
    has_many :reminder_mailings, through: :reminder_mailing_volunteers

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
    scope :start_at_or_before, ->(date) { where('period_start <= ?', date) }
    scope :start_after, ->(date) { where('period_start > ?', date) }
    scope :start_at_or_after, ->(date) { where('period_start >= ?', date) }
    scope :start_within, ->(date_range) { where(period_start: date_range) }
    scope :started_six_months_ago, (-> { where('period_start < ?', 6.months.ago) })
    scope :started_ca_six_weeks_ago, lambda {
      start_at_or_after(8.weeks.ago).start_at_or_before(6.weeks.ago)
    }

    scope :with_hours, (-> { joins(:hours) })

    scope :loj_mailings, lambda {
      left_outer_joins(:reminder_mailing_volunteers, :reminder_mailings)
    }
    scope :active, (-> { not_ended.started })
    scope :stay_active, (-> { active.no_end })
    scope :inactive, (-> { ended.or(no_start) })
    scope :active_between, lambda { |start_date, end_date|
      no_end.start_before(end_date)
            .or(start_before(end_date).end_after(start_date))
    }

    scope :internal, (-> { joins(:volunteer).merge(Volunteer.internal) })
    scope :external, (-> { joins(:volunteer).merge(Volunteer.external) })

    scope :no_reminder_mailing, lambda {
      loj_mailings.where('reminder_mailing_volunteers.id IS NULL')
    }

    scope :need_probation_period_reminder_mailing, lambda {
      started_ca_six_weeks_ago.no_reminder_mailing
    }

    scope :with_reminder_mailing_kind, lambda { |kind_number|
      loj_mailings.where('reminder_mailings.kind = ?', kind_number)
    }

    scope :with_half_year_reminder_mailing, lambda {
      with_reminder_mailing_kind(0)
    }

    scope :with_probation_period_reminder_mailing, lambda {
      with_reminder_mailing_kind(1)
    }

    scope :no_half_year_reminder_mailing, lambda {
      loj_mailings
        .where('reminder_mailings.kind != 1 OR reminder_mailing_volunteers.id IS NULL')
    }

    def started_six_months_ago?
      period_start < 6.months.ago
    end

    def started_ca_six_weeks_ago?
      period_start < 6.weeks.ago && period_start > 8.weeks.ago
    end
  end
end
