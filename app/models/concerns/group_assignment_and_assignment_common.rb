module GroupAssignmentAndAssignmentCommon
  extend ActiveSupport::Concern

  included do
    include TerminationScopes

    belongs_to :volunteer
    accepts_nested_attributes_for :volunteer

    has_many :reminder_mailing_volunteers, as: :reminder_mailable, dependent: :destroy
    has_many :reminder_mailings, through: :reminder_mailing_volunteers

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
    scope :started, (-> { date_at_or_before(Time.zone.today) })
    scope :will_start, (-> { date_after(Time.zone.today) })
    scope :start_before, ->(date) { date_before(:period_start, date) }
    scope :start_at_or_before, ->(date) { date_at_or_before(:period_start, date) }
    scope :start_after, ->(date) { date_after(:period_start, date) }
    scope :start_at_or_after, ->(date) { date_at_or_after(:period_start, date) }

    scope :start_within, lambda { |start_date, end_date|
      date_between_inclusion(:period_start, start_date, end_date)
    }

    scope :started_six_months_ago, (-> { date_at_or_before(:period_start, 6.months.ago) })
    scope :started_ca_six_weeks_ago, lambda {
      date_at_or_after(:period_start, 8.weeks.ago).date_at_or_before(:period_start, 6.weeks.ago)
    }
    scope :no_start_and_end, (-> { no_start.no_end })

    scope :with_hours, (-> { joins(:hours) })

    scope :loj_mailings, lambda {
      left_outer_joins(:reminder_mailing_volunteers, :reminder_mailings)
    }
    scope :active, (-> { not_ended.started.or(no_start.end_in_future) })
    scope :stay_active, (-> { active.no_end })
    scope :inactive, (-> { ended.or(no_start_and_end).or(will_start) })
    scope :active_between, lambda { |start_date, end_date|
      no_end.start_before(end_date)
            .or(start_before(end_date).end_after(start_date))
    }

    scope :internal, (-> { joins(:volunteer).merge(Volunteer.internal) })
    scope :external, (-> { joins(:volunteer).merge(Volunteer.external) })

    scope :no_reminder_mailing, lambda {
      loj_mailings.where('reminder_mailing_volunteers.id IS NULL')
                  .or(
                    loj_mailings.where('reminder_mailing_volunteers.picked = FALSE')
                  )
    }

    scope :need_trial_period_reminder_mailing, lambda {
      started_ca_six_weeks_ago.no_reminder_mailing
    }

    scope :with_reminder_mailing_kind, lambda { |kind_number|
      loj_mailings.where('reminder_mailings.kind = ?', kind_number)
    }

    scope :with_half_year_reminder_mailing, lambda {
      with_reminder_mailing_kind(0)
    }

    scope :with_trial_period_reminder_mailing, lambda {
      with_reminder_mailing_kind(1)
    }

    scope :submitted_since, lambda { |date|
      started.where("#{model_name.plural}.submitted_at < ?", date)
             .or(
               started.where("#{model_name.plural}.submitted_at IS NULL")
             )
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
