module GroupAssignmentAndAssignmentCommon
  extend ActiveSupport::Concern

  included do
    include TerminationScopes
    include PeriodStartEndScopesAndMethods

    belongs_to :volunteer
    accepts_nested_attributes_for :volunteer, update_only: true

    has_many :reminder_mailing_volunteers, as: :reminder_mailable, dependent: :destroy
    has_many :reminder_mailings, through: :reminder_mailing_volunteers

    # we have PDFs on Assignment and GroupAssignment, but not on *Log
    if [Assignment, GroupAssignment].include? self
      has_attached_file :pdf
      validates_attachment_content_type :pdf, content_type: Mime[:pdf]
      attribute :generate_pdf, :boolean
    end

    attribute :remaining_hours
    after_save :add_remaining_hours

    scope :with_hours, (-> { joins(:hours) })

    scope :loj_mailings, lambda {
      left_outer_joins(:reminder_mailing_volunteers, :reminder_mailings)
    }

    scope :internal, (-> { joins(:volunteer).merge(Volunteer.internal) })
    scope :external, (-> { joins(:volunteer).merge(Volunteer.external) })

    scope :with_actively_registered_volunteer, lambda {
      joins(:volunteer).merge(Volunteer.with_actively_registered_user)
    }

    scope :no_reminder_mailing, lambda {
      loj_mailings.where('reminder_mailing_volunteers.id IS NULL')
                  .or(
                    loj_mailings.where('reminder_mailing_volunteers.picked = FALSE')
                  )
    }

    scope :need_trial_period_reminder_mailing, lambda {
      active.start_before(5.weeks.ago).no_reminder_mailing
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

    def submit_feedback=(submitter)
      self.submitted_at = Time.zone.now
      self.submitted_by = submitter
    end

    def termination_verifiable?
      ended? && termination_submitted_by.present?
    end

    def terminated?
      termination_verifiable? && termination_verified_by.present?
    end

    private

    def add_remaining_hours
      return unless remaining_hours?

      polymorph_url_object.hours.create!(
        hours: remaining_hours,
        meeting_date: period_end,
        volunteer: volunteer
      )

      self.remaining_hours = nil
    end
  end
end
