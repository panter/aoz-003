class ReminderMailing < ApplicationRecord
  before_update :remove_untoggled_volunteers

  TEMPLATE_VARNAMES = [
    :Anrede,
    :Name,
    :Einsatz,
    :EinsatzStart,
    :FeedbackLink,
    :EmailAbsender
  ].freeze

  belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: 'reminder_mailings'

  # nullify on delete in order to keep sent mail links available
  has_many :reminder_mailing_volunteers, dependent: :delete_all
  accepts_nested_attributes_for :reminder_mailing_volunteers

  has_many :volunteers, through: :reminder_mailing_volunteers
  has_many :users, through: :volunteers

  has_many :assignments, through: :reminder_mailing_volunteers, source: :reminder_mailable,
    source_type: 'Assignment'
  has_many :group_assignments, through: :reminder_mailing_volunteers, source: :reminder_mailable,
    source_type: 'GroupAssignment'
  has_many :process_submitters, through: :reminder_mailing_volunteers, source: :process_submitted_by

  enum kind: { half_year: 0, trial_period: 1, termination: 2, half_year_process_email: 3, half_year_process_overdue: 4  }
  ransacker :kind, formatter: ->(value) { kinds[value] }

  validates :subject, presence: true
  validates :body, presence: true

  validate :no_reminder_volunteer_present, unless: :reminder_volunteer_mailings_any?
  validate :mailing_not_to_change_after_sent

  # setter generates relation to assignment/group_assignment and volunteer in one go
  def reminder_mailing_volunteers=(reminder_mailable)
    if [Assignment, GroupAssignment].include? reminder_mailable.first&.class
      super(reminder_mailable.map do |mailable|
        ReminderMailingVolunteer.new(volunteer: mailable.volunteer, reminder_mailable: mailable)
      end)
    else
      super(reminder_mailable)
    end
  end

  def submission_count
    reminder_mailing_volunteers.count(&:current_submission)
  end

  def self.kind_collection
    kinds.keys.map do |key|
      {
        q: :kind_eq,
        value: key,
        text: I18n.t("reminder_mailings.kinds.#{key}")
      }
    end
  end

  private

  def remove_untoggled_volunteers
    return unless will_save_change_to_sending_triggered?
    reminder_mailing_volunteers.reject(&:picked?).map(&:delete)
  end

  def selected_volunteers_any?
    reminder_mailing_volunteers.select(&:picked?).any?
  end

  def reminder_volunteer_mailings_any?
    reminder_mailing_volunteers.ids.any? || selected_volunteers_any?
  end

  def no_reminder_volunteer_present
    errors.add(:volunteers, 'Es muss mindestens ein/e Freiwillige/r ausgewählt sein.')
  end

  def mailing_not_to_change_after_sent
    if sending_triggered && !will_save_change_to_sending_triggered?
      errors.add(:already_sent, 'Wenn das Mailing bereits versendet wurde, kann es nicht mehr '\
        'geändert werden.')
    end
  end
end
