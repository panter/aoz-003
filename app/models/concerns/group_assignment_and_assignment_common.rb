module GroupAssignmentAndAssignmentCommon
  extend ActiveSupport::Concern

  included do
    include TerminationScopes
    include PeriodStartEndScopesAndMethods

    belongs_to :volunteer
    accepts_nested_attributes_for :volunteer

    has_many :reminder_mailing_volunteers, as: :reminder_mailable, dependent: :destroy
    has_many :reminder_mailings, through: :reminder_mailing_volunteers

    scope :with_hours, (-> { joins(:hours) })

    scope :loj_mailings, lambda {
      left_outer_joins(:reminder_mailing_volunteers, :reminder_mailings)
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

    def termination_feedback_submitted?
      termination_submitted_by.present? &&
        [term_feedback_activities, term_feedback_success, term_feedback_problems, term_feedback_transfair].any?
    end
  end
end
