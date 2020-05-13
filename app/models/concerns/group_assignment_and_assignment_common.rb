module GroupAssignmentAndAssignmentCommon
  extend ActiveSupport::Concern

  included do
    include TerminationScopes
    include PeriodStartEndScopesAndMethods

    belongs_to :volunteer
    accepts_nested_attributes_for :volunteer, update_only: true

    has_many :reminder_mailing_volunteers, as: :reminder_mailable, dependent: :destroy
    has_many :reminder_mailings, through: :reminder_mailing_volunteers

    has_one :trial_period, as: :trial_period_mission, inverse_of: :trial_period_mission
    accepts_nested_attributes_for :trial_period

    # we have PDFs on Assignment and GroupAssignment, but not on *Log
    if [Assignment, GroupAssignment].include? self
      has_attached_file :pdf
      validates_attachment_content_type :pdf, content_type: Mime[:pdf]
      attribute :generate_pdf, :boolean
    end

    attribute :remaining_hours

    after_initialize :handle_missing_trial_period!
    after_save :add_remaining_hours

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

    scope :with_reminder_mailing_kind, lambda { |kind_number|
      loj_mailings.where('reminder_mailings.kind = ?', kind_number)
    }

    scope :submitted_since, lambda { |date|
      started.where("#{model_name.plural}.submitted_at < ?", date)
        .or(
          started.where("#{model_name.plural}.submitted_at IS NULL")
        )
    }

    def submit_feedback=(submitter)
      self.submitted_at = Time.zone.now
      self.submitted_by = submitter
    end

    def termination_verifiable?
      ended? && termination_submitted_by.present?
    end

    def terminated?
      ended? && termination_verified_by.present?
    end

    def reactivatable?
      terminated? && dependency_allows_reactivation? && volunteer.accepted?
    end

    def reactivate!(user)
      update!(period_end: nil, termination_verified_at: nil, termination_submitted_at: nil, termination_verified_by: nil,
        termination_submitted_by: nil, period_end_set_by: nil, reactivated_by: user, reactivated_at: Time.zone.now)
      if assignment?
        assignment_log.delete
      elsif group_assignment?
        group_assignment_logs.last.delete
      end
    end

    private

    def handle_missing_trial_period!
      self.trial_period = TrialPeriod.new if trial_period.blank?
    end

    def dependency_allows_reactivation?
      if assignment?
        client.accepted?
      else
        !group_offer.terminated?
      end
    end

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
